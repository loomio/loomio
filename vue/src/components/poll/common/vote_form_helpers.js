import { marked } from 'marked';

export function sliderTicks(minimum, maximum) {
  if (maximum - minimum > 10) return {[minimum]: String(minimum), [maximum]: String(maximum)};
  return Object.fromEntries(Array.from({length: maximum - minimum + 1}, (_, index) => {
    const score = minimum + index;
    return [score, String(score)];
  }));
}

// Numeric fields can contain strings or be cleared. Keep valid zeroes while
// rejecting empty, fractional, negative, and out-of-range ballot scores.
export function scoresWithinRange(choices, minimum, maximum) {
  return choices.every(({score}) => {
    const number = Number(score);
    return score !== '' && score !== null && Number.isInteger(number) &&
      number >= Math.max(0, minimum) && (maximum == null || number <= maximum);
  });
}

export function responseText(stance) {
  const html = stance.reasonFormat === 'md' ? marked.parse(stance.reason) : stance.reason;
  return new DOMParser().parseFromString(html, 'text/html').body.textContent;
}
