export function voteWeightValid(value) {
  const text = String(value).trim();
  return /^(?:0|[1-9]\d{0,8})(?:\.\d+)?$/.test(text) && Number(text) <= 999999999.999;
}
