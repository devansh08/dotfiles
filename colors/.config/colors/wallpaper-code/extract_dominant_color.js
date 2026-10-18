const sharp = require('sharp');

/**
 * Extract the dominant color from an image using median cut algorithm.
 * Uses sharp to decode the image and then computes a representative color.
 *
 * @param {string} imagePath - Path to the image file
 * @returns {Promise<string>} Hex color string (#RRGGBB)
 */
async function extractDominantColors(imagePath, topN = 3) {
  // Get raw pixel data from sharp (resize for speed, keep quality reasonable)
  const { data, info } = await sharp(imagePath)
    .resize(50, 50, { fit: 'inside', withoutEnlargement: true })
    .raw()
    .toBuffer({ resolveWithObject: true });

  // Convert raw buffer to array of [r, g, b] tuples
  const pixels = [];
  for (let i = 0; i < data.length; i += 3) {
    pixels.push([data[i], data[i + 1], data[i + 2]]);
  }

  if (pixels.length === 0) {
    return ['#000000'];
  }

  // Median Cut algorithm to find dominant colors
  const palette = medianCut(pixels, 8); // Get top 8 colors

  // Score each color by how many pixels are closest to it
  const scores = palette.map((color) => {
    let count = 0;
    for (const pixel of pixels) {
      const dist = euclideanDistance(color, pixel);
      if (dist < 50) { // Threshold: "close enough" to this cluster
        count++;
      }
    }
    return { color, score: count };
  });

  // Sort by score descending
  scores.sort((a, b) => b.score - a.score);

  // Return top N colors as hex strings
  return scores.slice(0, topN).map((s) => rgbToHex(s.color[0], s.color[1], s.color[2]));
}

/**
 * Median Cut: recursively split pixel set into K color clusters.
 */
function medianCut(pixels, numColors) {
  if (pixels.length === 0 || numColors <= 0) return [];

  let buckets = [pixels];

  while (buckets.length < numColors) {
    // Find the bucket with the widest channel range
    let maxRange = -1;
    let splitIndex = 0;

    for (let i = 0; i < buckets.length; i++) {
      const bucket = buckets[i];
      if (bucket.length < 2) continue;

      const ranges = getChannelRanges(bucket);
      const maxChannel = ranges.reduce((max, r, idx) =>
        r.max - r.min > max.range ? { range: r.max - r.min, channel: idx } : max
      , { range: -1, channel: 0 });

      if (maxChannel.range > maxRange) {
        maxRange = maxChannel.range;
        splitIndex = i;
      }
    }

    if (maxRange < 0) break; // All buckets are uniform

    const bucket = buckets[splitIndex];
    const ranges = getChannelRanges(bucket);
    const channel = ranges.reduce((max, r, idx) =>
      r.max - r.min > max.range ? { range: r.max - r.min, channel: idx } : max
    , { range: -1, channel: 0 });

    // Sort by the widest channel and split in half
    bucket.sort((a, b) => a[channel.channel] - b[channel.channel]);
    const mid = Math.floor(bucket.length / 2);

    buckets.splice(splitIndex, 1, bucket.slice(0, mid), bucket.slice(mid));
  }

  // Return average color of each bucket
  return buckets.map((bucket) => {
    const avg = [0, 0, 0];
    for (const pixel of bucket) {
      avg[0] += pixel[0];
      avg[1] += pixel[1];
      avg[2] += pixel[2];
    }
    return [
      Math.round(avg[0] / bucket.length),
      Math.round(avg[1] / bucket.length),
      Math.round(avg[2] / bucket.length),
    ];
  });
}

function getChannelRanges(bucket) {
  let rMin = 255, rMax = 0, gMin = 255, gMax = 0, bMin = 255, bMax = 0;
  for (const p of bucket) {
    if (p[0] < rMin) rMin = p[0]; if (p[0] > rMax) rMax = p[0];
    if (p[1] < gMin) gMin = p[1]; if (p[1] > gMax) gMax = p[1];
    if (p[2] < bMin) bMin = p[2]; if (p[2] > bMax) bMax = p[2];
  }
  return [
    { min: rMin, max: rMax },
    { min: gMin, max: gMax },
    { min: bMin, max: bMax },
  ];
}

function euclideanDistance(a, b) {
  return Math.sqrt((a[0] - b[0]) ** 2 + (a[1] - b[1]) ** 2 + (a[2] - b[2]) ** 2);
}

function rgbToHex(r, g, b) {
  return '#' + [r, g, b].map((c) => c.toString(16).padStart(2, '0')).join('').toUpperCase();
}

module.exports = { extractDominantColors };
