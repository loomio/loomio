import emojiLib from 'emojilib';

// emojiLib is keyed by unicode glyph -> [canonical_shortcode, *keywords].
// Flatten to {shortcode: glyph} so the picker and any callers iterate by name.
export const emojis = (() => {
  const out = {};
  for (const [glyph, [code, ...keywords]] of Object.entries(emojiLib)) {
    out[code] = glyph;
  }
  return out;
})();

// A small set of shortcodes that frequently get used and that we want to
// surface even when the user has not typed anything specific. Pinned at the
// top of the picker so common picks (smile, heart, thumbs up, tada, ...) are
// one click away regardless of scroll position.
export const frequentEmojis = [
  'slightly_smiling_face',
  'red_heart',
  'thumbs_up',
  'party_popper',
  'clapping_hands',
  'thinking_face',
  'ok_hand',
  'folded_hands',
  'waving_hand'
].map(code => ({ shortcode: code, unicode: emojis[code] }))
 .filter(e => e.unicode);

// Search emoji by shortcode or emojilib keyword. Returns matching entries
// as the user types; an empty string returns an empty array (callers render
// the full grid instead).
export function searchEmojis(query) {
  if (!query) { return []; }
  const q = query.toLowerCase();
  const results = [];
  for (const [glyph, [code, ...keywords]] of Object.entries(emojiLib)) {
    if (code.includes(q) || keywords.some(k => k.includes(q))) {
      results.push({ shortcode: code, unicode: glyph });
    }
  }
  return results;
}