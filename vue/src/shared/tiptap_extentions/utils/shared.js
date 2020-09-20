/**
 * Utils: shared
 * @author Leecason
 * @license MIT, https://github.com/Leecason/element-tiptap/blob/master/LICENSE
 * @see https://github.com/Leecason/element-tiptap/blob/master/src/utils/shared.ts
 */

export function noop () {}

/**
 * Check whether a value is NaN
 */
export function isNaN (val) {
  return Number.isNaN(val)
}

export function clamp (val, min, max) {
  if (val < min) {
    return min
  }
  if (val > max) {
    return max
  }
  return val
}

export function readFileDataUrl (file) {
  const reader = new FileReader()

  return new Promise((resolve, reject) => {
    // @ts-ignore
    reader.onload = readerEvent => resolve(readerEvent.target.result)
    reader.onerror = reject

    reader.readAsDataURL(file)
  })
}

/**
 * Create a cached version of a pure function.
 */
export function cached (fn) {
  const cache = Object.create(null)

  return function cachedFn (str) {
    const hit = cache[str]
    return hit || (cache[str] = fn(str))
  }
}

/**
 * Capitalize a string.
 */
export const capitalize = cached((str) => {
  return str.charAt(0).toUpperCase() + str.slice(1)
})

/**
 * Strict object type check. Only returns true
 * for plain JavaScript objects.
 */
export function isPlainObject (obj) {
  return Object.prototype.toString.call(obj) === '[object Object]'
}

/**
 * RGB to HEX
 * @param color rgb(x, y, x)
 * @returns {string} #000000
 */
export function rgbToHex (rgb) {
  if (!rgb.startsWith('rgb')) {
    return rgb
  }

  let splits = rgb.split(',')
  let r = parseInt(splits[0].split('(')[1], 10)
  let g = parseInt(splits[1], 10)
  let b = parseInt(splits[2].split(')')[0], 10)
  let hex = '#' + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1)

  return hex
}

export function hexToRgb (hex) {
  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex)

  return result ? {
    r: parseInt(result[1], 16),
    g: parseInt(result[2], 16),
    b: parseInt(result[3], 16)
  } : null
}

export function highlightColor (rgb) {
  if (!rgb.startsWith('rgb')) {
    return rgb
  }

  let splits = rgb.split(',')
  let r = parseInt(splits[0].split('(')[1], 10)
  let g = parseInt(splits[1], 10)
  let b = parseInt(splits[2].split(')')[0], 10)
  let sum = r + g + b
  let color = '#000000'
  if (sum < 180 * 3) {
    color = '#ffffff'
  }

  return color
}

export function openUrl (url) {
  window.open(url, '_blank')
}
