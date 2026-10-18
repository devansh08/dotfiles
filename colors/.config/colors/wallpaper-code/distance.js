/**
 * Color distance calculation utilities.
 * Isolated module so different metrics can be swapped easily.
 */

/**
 * Euclidean distance in RGB space between two hex colors.
 * @param {string} hex1 - First hex color (#RRGGBB)
 * @param {string} hex2 - Second hex color (#RRGGBB)
 * @returns {number} Distance value
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
 * Convert hex color to RGB object.
 */
function hexToRgb(hex) {
  const cleaned = hex.replace('#', '');
  return {
    r: parseInt(cleaned.substring(0, 2), 16),
    g: parseInt(cleaned.substring(2, 4), 16),
    b: parseInt(cleaned.substring(4, 6), 16),
  };
}

module.exports = { euclideanDistance, hexToRgb };
