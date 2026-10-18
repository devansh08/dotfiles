#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const os = require("os");
const crypto = require("crypto");
const sharp = require("sharp");
const { extractDominantColors } = require("./extract_dominant_color");
const { colorDistance } = require("./distance_colorjs");

// ─── Config ────────────────────────────────────────────────────────────────────

const HOME = process.env.HOME || os.homedir();
const SCRIPT_DIR = path.dirname(__filename);
const THEME_PATH = path.join(HOME, ".active_theme", "theme.json");
// const WALLPAPER_DIR = path.join(HOME, '.config', 'colors', 'wallpapers');
const WALLPAPER_DIR = path.join(HOME, "Weave", "home", "mystra", ".wallpapers");
const CACHE_PATH = path.join(SCRIPT_DIR, "cache.json");
const OUTPUT_HTML = path.join(SCRIPT_DIR, "output.html");
const THUMB_DIR = path.join(SCRIPT_DIR, "thumbnails");
const TOP_N = 300;
const THUMB_WIDTH = 400; // thumbnail max width

// ─── Helpers ───────────────────────────────────────────────────────────────────

function formatBytes(bytes) {
  if (bytes === 0) return "0 B";
  const k = 1024;
  const sizes = ["B", "KB", "MB", "GB"];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + " " + sizes[i];
}

function escapeHtml(str) {
  return String(str)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

function pathToThumbHash(filePath) {
  return crypto.createHash("md5").update(filePath).digest("hex") + ".jpg";
}

function thumbPath(filePath) {
  const hash = pathToThumbHash(filePath);
  return path.join(THUMB_DIR, hash);
}

async function generateThumbnail(imagePath) {
  try {
    const stat = fs.statSync(imagePath);
    // Only regenerate if file changed since last thumbnail was created
    const thumbFile = thumbPath(imagePath);
    if (fs.existsSync(thumbFile)) {
      const thumbStat = fs.statSync(thumbFile);
      if (thumbStat.mtimeMs >= stat.mtimeMs) {
        return { path: thumbFile, sizeBytes: thumbStat.size };
      }
    }
    // Generate new thumbnail
    await sharp(imagePath)
      .resize(THUMB_WIDTH, THUMB_WIDTH, { fit: "contain", withoutEnlargement: true })
      .jpeg({ quality: 75 })
      .toFile(thumbFile);
    const thumbStat = fs.statSync(thumbFile);
    return { path: thumbFile, sizeBytes: thumbStat.size };
  } catch (err) {
    console.error("Error generating thumbnail for " + imagePath + ": " + err.message);
    return null;
  }
}

// ─── Step 1: Read accent_primary from theme.json ───────────────────────────────

function readAccentPrimary() {
  const raw = fs.readFileSync(THEME_PATH, "utf-8");
  const theme = JSON.parse(raw);
  if (!theme.accent_primary) {
    throw new Error("accent_primary not found in " + THEME_PATH);
  }
  return theme.accent_primary;
}

// ─── Step 2: Recursively find all image files ──────────────────────────────────

function findWallpapers(dir) {
  const extensions = new Set([".jpg", ".jpeg", ".png"]);
  let results = [];

  function walk(currentDir) {
    const entries = fs.readdirSync(currentDir, { withFileTypes: true });
    for (const entry of entries) {
      const fullPath = path.join(currentDir, entry.name);
      if (entry.isDirectory()) {
        walk(fullPath);
      } else if (
        entry.isFile() &&
        extensions.has(path.extname(entry.name).toLowerCase())
      ) {
        results.push(fullPath);
      }
    }
  }

  walk(dir);
  return results;
}

// ─── Cache schema: { [filePath]: { hash, colors[], width, height, sizeBytes } } ─
// Hash is stored so we never recompute it. Deduplication checks against cached hashes.

function loadCache() {
  if (fs.existsSync(CACHE_PATH)) {
    try {
      return JSON.parse(fs.readFileSync(CACHE_PATH, "utf-8"));
    } catch {
      return {};
    }
  }
  return {};
}

function saveCache(cache) {
  fs.writeFileSync(CACHE_PATH, JSON.stringify(cache, null, 2), "utf-8");
}

function fileHash(filePath) {
  try {
    const buf = fs.readFileSync(filePath);
    return crypto.createHash("md5").update(buf).digest("hex");
  } catch {
    return null;
  }
}

async function processWallpapers(wallpapers, cache) {
  // Ensure thumbnails directory exists
  if (!fs.existsSync(THUMB_DIR)) {
    fs.mkdirSync(THUMB_DIR, { recursive: true });
  }

  // Build hash→canonical-path map from existing cache entries
  const cachedHashes = new Map(); // hash -> first file path that has this hash in cache
  for (const [filePath, info] of Object.entries(cache)) {
    if (
      info &&
      typeof info === "object" &&
      Array.isArray(info.colors) &&
      info.hash
    ) {
      if (!cachedHashes.has(info.hash)) {
        cachedHashes.set(info.hash, filePath);
      }
    }
  }

  let processed = 0;
  let fromCache = 0;
  let skippedByHash = 0;
  let newlyComputed = 0;
  const seenNewHashes = new Map(); // hash -> first path among newly-hashed files

  console.log("Processing " + wallpapers.length + " files (cache has " + Object.keys(cache).length + " entries)...");

  for (const filePath of wallpapers) {
    const cached = cache[filePath];
    if (cached && typeof cached === "object" && Array.isArray(cached.colors)) {
      fromCache++;
      processed++;
      continue;
    }

    // New file: compute hash and check for duplicates against both cached and new hashes
    const h = fileHash(filePath);
    if (h) {
      // Skip if this exact content already exists in cache
      if (cachedHashes.has(h)) {
        skippedByHash++;
        processed++;
        continue;
      }
      // Skip if we've already hashed this duplicate among new files
      if (seenNewHashes.has(h)) {
        skippedByHash++;
        processed++;
        continue;
      }
      seenNewHashes.set(h, filePath);
    }

    try {
      console.time("extract-colors: " + filePath);
      const colors = await extractDominantColors(filePath, 3);
      console.timeEnd("extract-colors: " + filePath);

      console.time("stat+meta: " + filePath);
      const stat = fs.statSync(filePath);
      const meta = await sharp(filePath).metadata();
      console.timeEnd("stat+meta: " + filePath);

      console.time("thumbnail: " + filePath);
      // Generate thumbnail for HTML display
      const thumb = await generateThumbnail(filePath);
      console.timeEnd("thumbnail: " + filePath);
      cache[filePath] = {
        hash: h,
        colors: colors,
        width: meta.width || "unknown",
        height: meta.height || "unknown",
        sizeBytes: stat.size,
        thumbPath: thumb ? thumb.path : null,
        thumbSize: thumb ? thumb.sizeBytes : 0,
      };
    } catch (err) {
      console.error("Error processing " + filePath + ": " + err.message);
      continue;
    }
    newlyComputed++;
    processed++;
    if (processed % 100 === 0) {
      console.log(
        "Processed " + processed + "/" + wallpapers.length + " | cache=" + fromCache + " new=" + newlyComputed + " dup=" + skippedByHash,
      );
    }
  }

  saveCache(cache);
  return { processed, fromCache, skippedByHash, newlyComputed };
}

// ─── Step 4: Filter top N closest to accent_primary ────────────────────────────

function getClosestImages(cache, accentPrimary, topN) {
  const entries = Object.entries(cache).map(([filePath, info]) => {
    // Find the closest color among the 3
    let minDist = Infinity;
    for (const color of info.colors) {
      const d = colorDistance(color, accentPrimary);
      if (d < minDist) minDist = d;
    }
    return {
      filePath,
      colors: info.colors,
      width: info.width,
      height: info.height,
      sizeBytes: info.sizeBytes,
      thumbPath: info.thumbPath || null,
      distance: minDist,
    };
  });

  entries.sort((a, b) => a.distance - b.distance);
  return entries.slice(0, topN);
}

// ─── Step 5 & 6: Generate standalone HTML page ─────────────────────────────────

function generateHTML(closestImages, accentPrimary) {
  const images = closestImages.map((item) => ({
    src: item.thumbPath ? "file://" + item.thumbPath : "",
    colors: item.colors,
    distance: item.distance.toFixed(2),
    path: escapeHtml(item.filePath),
    resolution: item.width + "\u00d7" + item.height,
    sizeBytes: item.sizeBytes,
    extension: item.filePath.split(".").pop().toUpperCase(),
  }));

  const cardHTML = images
    .map(function (img, i) {
      // Build color swatches for all 3 colors
      var colorSwatches = "";
      for (var j = 0; j < img.colors.length; j++) {
        colorSwatches +=
          '<span class="color-dot" style="background:' +
          img.colors[j] +
          '" title="Color ' +
          (j + 1) +
          '"></span>\n';
      }

      return (
        '    <div class="card">\n' +
        '      <img src="' +
        img.src +
        '" alt="Wallpaper ' +
        (i + 1) +
        '" loading="lazy" onerror="this.style.display=\'none\'" />\n' +
        '      <div class="card-body">\n' +
        '        <div class="meta-row">\n' +
        '          <span class="meta-item">' +
        img.resolution +
        "</span>\n" +
        '          <span class="meta-item">' +
        formatBytes(img.sizeBytes) +
        "</span>\n" +
        '          <span class="meta-item">' +
        img.extension +
        "</span>\n" +
        "        </div>\n" +
        '        <div class="card-color">\n' +
        "          " +
        colorSwatches +
        "          Best match: \u0394E: " +
        img.distance +
        "\n" +
        "        </div>\n" +
        '        <div class="color-list">' +
        img.colors.join(" • ") +
        "</div>\n" +
        '        <button class="copy-btn" data-path="' +
        img.path +
        '" onclick="copyPath(this)">Copy Path</button>\n' +
        "      </div>\n" +
        "    </div>"
      );
    })
    .join("\n");

  var html = [
    "<!DOCTYPE html>",
    '<html lang="en">',
    "<head>",
    '  <meta charset="UTF-8" />',
    '  <meta name="viewport" content="width=device-width, initial-scale=1.0" />',
    "  <title>Wallpaper Matches \u2014 Accent: " +
      escapeHtml(accentPrimary) +
      "</title>",
    "  <style>",
    "    * { margin: 0; padding: 0; box-sizing: border-box; }",
    "    body {",
    '      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;',
    "      background: #1a1a1a;",
    "      color: #e0e0e0;",
    "      padding: 24px;",
    "    }",
    "    h1 { margin-bottom: 8px; font-size: 1.5rem; }",
    "    .accent-badge {",
    "      display: inline-flex; align-items: center; gap: 8px;",
    "      background: #2a2a2a; padding: 6px 14px; border-radius: 8px;",
    "      font-family: monospace; font-size: 0.95rem; margin-bottom: 24px;",
    "    }",
    "    .accent-swatch {",
    "      width: 16px; height: 16px; border-radius: 3px;",
    "      background: " + accentPrimary + "; border: 1px solid #555;",
    "    }",
    "    .grid {",
    "      display: grid;",
    "      grid-template-columns: repeat(auto-fill, minmax(330px, 1fr));",
    "      gap: 16px;",
    "    }",
    "    .card {",
    "      background: #2a2a2a; border-radius: 10px; overflow: hidden;",
    "      transition: transform 0.15s ease;",
    "    }",
    "    .card:hover { transform: translateY(-3px); }",
    "    .card img {",
    "      width: 100%; height: 180px; object-fit: cover; display: block;",
    "      background: #333;",
    "    }",
    "    .card img[src=\"\"] {",
    "      display: none;",
    "    }",
    "    .card-body { padding: 12px; }", 
    "    .card-color {",
    "      display: flex; align-items: center; gap: 8px; margin-bottom: 6px;",
    "      font-size: 0.85rem; color: #aaa;",
    "    }",
    "    .color-dot {",
    "      width: 12px; height: 12px; border-radius: 3px; display: inline-block;",
    "    }",
    "    .distance-tag {",
    "      background: #3a3a3a; padding: 2px 8px; border-radius: 4px;",
    "      font-family: monospace; font-size: 0.8rem; color: #ccc;",
    "    }",
    "    .meta-row {",
    "      display: flex; gap: 12px; margin-bottom: 8px;",
    "      font-size: 0.75rem; color: #777;",
    "    }",
    "    .meta-item {",
    "      background: #3a3a3a; padding: 2px 8px; border-radius: 4px;",
    "      font-family: monospace;",
    "    }",
    "    .copy-btn {",
    "      width: 100%; padding: 8px; border: none; border-radius: 6px;",
    "      background: #444; color: #e0e0e0; cursor: pointer; font-size: 0.85rem;",
    "      transition: background 0.15s ease;",
    "    }",
    "    .copy-btn:hover { background: #555; }",
    "    .copy-btn.copied { background: #2d6a4f; color: #fff; }",
    "    .stats { margin-bottom: 16px; font-size: 0.85rem; color: #777; }",
    "    .color-list {",
    "      font-family: monospace; font-size: 0.75rem; color: #999;",
    "      margin-bottom: 8px;",
    "    }",
    "  </style>",
    "</head>",
    "<body>",
    "  <h1>Wallpaper Matches</h1>",
    '  <div class="accent-badge">',
    '    <span class="accent-swatch"></span>',
    "    Accent Primary: " + escapeHtml(accentPrimary),
    "  </div>",
    '  <p class="stats">Showing top ' +
      images.length +
      " wallpapers closest to accent color | Thumbnails generated locally</p>",
    '  <div class="grid">',
    cardHTML,
    "  </div>",
    "",
    "  <script>",
    "    function copyPath(btn) {",
    '      var filePath = btn.getAttribute("data-path");',
    "      navigator.clipboard.writeText(filePath).then(function() {",
    '        btn.textContent = "Copied!";',
    '        btn.classList.add("copied");',
    "        setTimeout(function() {",
    '          btn.textContent = "Copy Path";',
    '          btn.classList.remove("copied");',
    "        }, 1500);",
    "      }).catch(function() {",
    '        var ta = document.createElement("textarea");',
    "        ta.value = filePath;",
    "        document.body.appendChild(ta);",
    "        ta.select();",
    '        document.execCommand("copy");',
    "        document.body.removeChild(ta);",
    '        btn.textContent = "Copied!";',
    '        btn.classList.add("copied");',
    "        setTimeout(function() {",
    '          btn.textContent = "Copy Path";',
    '          btn.classList.remove("copied");',
    "        }, 1500);",
    "      });",
    "    }",
    "  <\/script>",
    "</body>",
    "</html>",
  ].join("\n");

  return html;
}

// ─── Main ──────────────────────────────────────────────────────────────────────

async function main() {
  console.log("Reading accent_primary from theme...");
  const accentPrimary = readAccentPrimary();
  console.log("   Accent: " + accentPrimary);

  console.time("scan");
  console.log("Scanning wallpapers in " + WALLPAPER_DIR + "...");
  let wallpapers = findWallpapers(WALLPAPER_DIR);
  console.log("   Found " + wallpapers.length + " image files.");
  console.timeEnd("scan");

  console.time("cache-load");
  console.log("Loading cache...");
  const cache = loadCache();
  console.log("   Cache entries: " + Object.keys(cache).length);
  console.timeEnd("cache-load");

  // Migrate old entries that lack hashes - hash them now so future runs skip correctly
  let migrated = 0;
  for (const [filePath, info] of Object.entries(cache)) {
    if (
      info &&
      typeof info === "object" &&
      Array.isArray(info.colors) &&
      !info.hash
    ) {
      const h = fileHash(filePath);
      if (h) {
        info.hash = h;
        migrated++;
      }
    }
  }
  if (migrated > 0) {
    console.log(
      "   Migrated " + migrated + " old cache entries to include hashes.",
    );
    saveCache(cache);
  }

  console.log("Extracting dominant colors...");
  const stats = await processWallpapers(wallpapers, cache);
  console.log(
    "   Processed: " + stats.processed + " | From cache: " + stats.fromCache + " | New: " + stats.newlyComputed + " | Duplicates skipped: " + stats.skippedByHash,
  );
  if (stats.skippedByHash > 0) {
    console.log(
      "   Skipped by hash dedup: " + stats.skippedByHash + " duplicate files.",
    );
  }

  // Generate thumbnails for cached entries that lack them (e.g., pre-existing cache)
  console.time("thumbnails-missing");
  console.log("Generating/verifying thumbnails for missing entries...");
  let thumbMissing = 0;
  let thumbUpdated = 0;
  for (const [filePath, info] of Object.entries(cache)) {
    if (
      info &&
      typeof info === "object" &&
      Array.isArray(info.colors) &&
      !info.thumbPath
    ) {
      const thumb = await generateThumbnail(filePath);
      if (thumb) {
        info.thumbPath = thumb.path;
        info.thumbSize = thumb.sizeBytes;
        thumbUpdated++;
      }
      thumbMissing++;
    }
  }
  if (thumbMissing > 0) {
    console.log(
      "   Updated: " + thumbUpdated + "/" + thumbMissing + " entries with thumbnails.",
    );
    saveCache(cache);
  }
  console.timeEnd("thumbnails-missing");

  console.time("closest");
  console.log("Finding closest matches...");
  const closestImages = getClosestImages(cache, accentPrimary, TOP_N);
  console.log("   Top " + TOP_N + " wallpapers selected.");
  console.timeEnd("closest");

  console.time("html");
  console.log("Generating HTML output...");
  const html = generateHTML(closestImages, accentPrimary);
  fs.writeFileSync(OUTPUT_HTML, html, "utf-8");
  console.log("   Saved to: " + OUTPUT_HTML);
  console.timeEnd("html");
  console.log("\nDone! Open the HTML file in your browser.");
}

main().catch(function (err) {
  console.error("Fatal error:", err);
  process.exit(1);
});
