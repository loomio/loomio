export const colorIsTransparent = color => {
  if (typeof color === 'object' && color !== null) {
    return color.a === 0;
  }

  if (typeof color !== 'string') { return false; }

  const value = color.trim().toLowerCase();

  if (value === 'transparent') { return true; }
  if (/^#[0-9a-f]{3}0$/.test(value)) { return true; }
  if (/^#[0-9a-f]{6}00$/.test(value)) { return true; }

  return /^(?:rgba?|hsla?|hsva?)\([^)]*(?:,|\/)\s*(?:0+(?:\.0+)?|0+%)\s*\)$/.test(value);
};
