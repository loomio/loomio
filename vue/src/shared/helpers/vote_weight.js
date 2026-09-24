export function voteWeightValid(value) {
  const text = String(value).trim();
  return /^(?:0|[1-9]\d{0,6})(?:\.\d{1,3})?$/.test(text) && Number(text) <= 1000000;
}
