/**
 * Color distance calculation using colorjs.io — CIEDE2000.
 * Replaces distance.js with perceptually accurate metrics.
 *
 * CIEDE2000 accounts for how human vision actually perceives color differences:
 * - Non-uniform sensitivity across hue/chroma/lightness
 * - Hue rotation effects near black/white
 * - Chroma-lightness interaction
 *
 * To switch, change the require in index.js:
 *   OLD: const { euclideanDistance } = require('./distance');
 *   NEW: const { colorDistance } = require('./distance_colorjs');
 */

const Color = require('colorjs.io').default || require('colorjs.io');

/**
 * CIEDE2000 distance between two hex colors.
 * Lower = more similar perceptually.
 *
 * ΔE < 1.0  → imperceptible
 * ΔE 1-2    → perceptible by trained eye
 * ΔE 2-10   → perceptible at a glance
 * ΔE > 10   → very different
 *
 * @param {string} hex1 - First hex color (#RRGGBB)
 * @param {string} hex2 - Second hex color (#RRGGBB)
 * @returns {number} CIEDE2000 distance (ΔE₀₀)
 */
function colorDistance(hex1, hex2) {
  const c1 = new Color(hex1);
  const c2 = new Color(hex2);
  return c1.deltaE2000(c2);
}

/**
 * Euclidean distance in RGB space (kept for comparison).
 */
function euclideanDistance(hex1, hex2) {
  const c1 = hexToRgb(hex1);
  const c2 = hexToRgb(hex2);
  return Math.sqrt(
    (c1.r - c2.r) ** 2 +
    (c1.g - c2.g) ** 2 +
    (c1.b - c2.b) ** 2
  );
}

/**
 * CIE76 (ΔE₇₆) — simple Lab Euclidean. Simpler than DE2000 but better than RGB.
 */
function colorDistance76(hex1, hex2) {
  const c1 = new Color(hex1);
  const c2 = new Color(hex2);
  return c1.deltaE76(c2);
}

/**
 * Convert hex to RGB object.
 */
function hexToRgb(hex) {
  const cleaned = hex.replace('#', '');
  return {
    r: parseInt(cleaned.substring(0, 2), 16),
    g: parseInt(cleaned.substring(2, 4), 16),
    b: parseInt(cleaned.substring(4, 6), 16),
  };
}

module.exports = { colorDistance, colorDistance76, euclideanDistance, hexToRgb };
