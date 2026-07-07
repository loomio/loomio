import englishEmojiData from 'emojibase-data/en/compact.json';

const emojiDataLoaders = {
  bn: () => import('emojibase-data/bn/compact.json'),
  da: () => import('emojibase-data/da/compact.json'),
  de: () => import('emojibase-data/de/compact.json'),
  en: () => import('emojibase-data/en/compact.json'),
  'en-gb': () => import('emojibase-data/en-gb/compact.json'),
  es: () => import('emojibase-data/es/compact.json'),
  'es-mx': () => import('emojibase-data/es-mx/compact.json'),
  et: () => import('emojibase-data/et/compact.json'),
  fi: () => import('emojibase-data/fi/compact.json'),
  fr: () => import('emojibase-data/fr/compact.json'),
  hi: () => import('emojibase-data/hi/compact.json'),
  hu: () => import('emojibase-data/hu/compact.json'),
  it: () => import('emojibase-data/it/compact.json'),
  ja: () => import('emojibase-data/ja/compact.json'),
  ko: () => import('emojibase-data/ko/compact.json'),
  lt: () => import('emojibase-data/lt/compact.json'),
  ms: () => import('emojibase-data/ms/compact.json'),
  nb: () => import('emojibase-data/nb/compact.json'),
  nl: () => import('emojibase-data/nl/compact.json'),
  pl: () => import('emojibase-data/pl/compact.json'),
  pt: () => import('emojibase-data/pt/compact.json'),
  ru: () => import('emojibase-data/ru/compact.json'),
  sv: () => import('emojibase-data/sv/compact.json'),
  th: () => import('emojibase-data/th/compact.json'),
  uk: () => import('emojibase-data/uk/compact.json'),
  vi: () => import('emojibase-data/vi/compact.json'),
  zh: () => import('emojibase-data/zh/compact.json'),
  'zh-hant': () => import('emojibase-data/zh-hant/compact.json')
};

const emojiEntriesByLocale = {};

const legacyAliases = {
  '+1': ['thumbs_up'],
  '-1': ['thumbs_down'],
  call_me: ['call_me_hand'],
  clap: ['clapping_hands'],
  heart: ['red_heart'],
  hankey: ['pile_of_poo'],
  laughing: ['grinning_squinting_face'],
  metal: ['sign_of_the_horns'],
  pray: ['folded_hands'],
  simple_smile: ['slightly_smiling_face'],
  slight_frown: ['frowning_face'],
  slight_smile: ['slightly_smiling_face'],
  tada: ['party_popper'],
  thumbsup: ['thumbs_up'],
  thumbsdown: ['thumbs_down'],
  v: ['victory_hand'],
  wave: ['waving_hand']
};

const unicodeOverrides = {
  thumbs_down: '👎',
  thumbs_up: '👍'
};

// A small set of shortcodes that frequently get used and that we want to
// surface even when the user has not typed anything specific. Pinned at the
// top of the picker so common picks (smile, heart, thumbs up, tada, ...) are
// one click away regardless of scroll position.
const frequentShortcodes = [
  'slightly_smiling_face',
  'red_heart',
  'thumbs_up',
  'party_popper',
  'clapping_hands',
  'thinking_face',
  'ok_hand',
  'folded_hands',
  'waving_hand',
  'face_with_tears_of_joy',
  'smiling_face_with_heart_eyes',
  'grinning_face_with_sweat',
  'face_with_rolling_eyes',
  'fire',
  'eyes',
  'rocket'
];

// Fitzpatrick skin tone modifiers, ordered light to dark. Index 0 here maps to
// the picker's tone 1 (the "default" tone 0 uses the base, un-toned emoji).
const skinToneHexcodes = ['1F3FB', '1F3FC', '1F3FD', '1F3FE', '1F3FF'];

// Swatch colours + i18n keys for the picker's skin tone menu. Index matches the
// tone value stored/applied (0 = default/yellow, 1-5 = light to dark).
export const skinTones = [
  { tone: 0, color: '#ffc93a', key: 'default' },
  { tone: 1, color: '#fadcbd', key: 'light' },
  { tone: 2, color: '#e0bb95', key: 'medium_light' },
  { tone: 3, color: '#bf8f68', key: 'medium' },
  { tone: 4, color: '#9b643d', key: 'medium_dark' },
  { tone: 5, color: '#594539', key: 'dark' }
];

// Resolve the unicode for an entry at the given skin tone (0 = base emoji).
// Falls back to the base emoji when the entry has no variant for that tone.
export function tonedUnicode(entry, tone) {
  if (!tone || !entry.skins) { return entry.unicode; }
  return entry.skins[tone - 1] || entry.unicode;
}

function emojiIsSelectable(emoji) {
  return emoji.group != null && emoji.group !== 2;
}

// Extract the single-tone variants for an emoji, ordered light to dark. For
// multi-person emojis (which also carry mixed-tone combinations) this keeps
// only the variant where every person shares the same tone. The tone modifier
// can appear mid-sequence in ZWJ emojis, so we match on the modifiers present
// rather than a fixed hexcode suffix.
function skinsFor(emoji) {
  if (!emoji.skins) { return null; }
  const byTone = {};
  emoji.skins.forEach(skin => {
    const tones = skin.hexcode.split('-').filter(part => skinToneHexcodes.includes(part));
    const distinct = [...new Set(tones)];
    if (distinct.length === 1) {
      const index = skinToneHexcodes.indexOf(distinct[0]);
      if (byTone[index] === undefined) { byTone[index] = skin.unicode; }
    }
  });
  const skins = skinToneHexcodes.map((hexcode, index) => byTone[index] || null);
  return skins.some(Boolean) ? skins : null;
}

function metadataKey(emoji) {
  return emoji.replace(/\uFE0F/g, '');
}

function metadataByEmoji(data) {
  const out = {};
  data.forEach(emoji => {
    out[metadataKey(emoji.unicode)] = emoji;
  });
  return out;
}

function shortcodeForLabel(label) {
  return normalizeSearchTerm(label)
    .replace(/&/g, ' and ')
    .replace(/[^a-z0-9+]+/g, '_')
    .replace(/^_+|_+$/g, '');
}

function normalizeSearchTerm(term) {
  return term.toLowerCase().normalize('NFD').replace(/\p{Diacritic}/gu, '');
}

function normalizeLocale(locale) {
  const normalized = (locale || 'en').replaceAll('_', '-').toLowerCase();
  const localeAliases = {
    'nl-nl': 'nl',
    'pt-br': 'pt',
    'zh-cn': 'zh',
    'zh-tw': 'zh-hant'
  };
  const candidate = localeAliases[normalized] || normalized.split('-')[0] || 'en';
  return emojiDataLoaders[candidate] ? candidate : 'en';
}

function canonicalEntryFor(english) {
  const shortcode = shortcodeForLabel(english.label);
  const skins = skinsFor(english);
  return {
    shortcode,
    unicode: unicodeOverrides[shortcode] || english.unicode,
    ...(skins ? { skins } : {})
  };
}

const canonicalEntries = englishEmojiData.filter(emojiIsSelectable).map(canonicalEntryFor);
const englishMetadata = metadataByEmoji(englishEmojiData);

function aliasesFor(shortcode) {
  return Object.keys(legacyAliases).filter(alias => legacyAliases[alias].includes(shortcode));
}

function entryFor(canonicalEntry, localizedMetadata) {
  const key = metadataKey(canonicalEntry.unicode);
  const english = englishMetadata[key] || {};
  const localized = localizedMetadata[key] || english;
  const label = localized.label || english.label || canonicalEntry.shortcode.replaceAll('_', ' ');
  const aliases = aliasesFor(canonicalEntry.shortcode);

  return {
    ...canonicalEntry,
    label,
    searchTerms: [
      canonicalEntry.shortcode,
      canonicalEntry.shortcode.replaceAll('_', ' '),
      ...aliases,
      ...aliases.map(alias => alias.replaceAll('_', ' ')),
      label,
      ...(localized.tags || []),
      english.label,
      ...(english.tags || [])
    ].filter(Boolean).map(normalizeSearchTerm)
  };
}

export async function loadEmojiEntries(locale) {
  const emojiLocale = normalizeLocale(locale);
  if (emojiEntriesByLocale[emojiLocale]) { return emojiEntriesByLocale[emojiLocale]; }

  const data = emojiLocale === 'en'
    ? englishEmojiData
    : (await emojiDataLoaders[emojiLocale]()).default;
  const localizedMetadata = metadataByEmoji(data);
  const entries = canonicalEntries.map(entry => entryFor(entry, localizedMetadata));

  emojiEntriesByLocale[emojiLocale] = entries;
  return entries;
}

export const emojis = canonicalEntries.reduce((out, entry) => {
  out[entry.shortcode] = entry.unicode;
  return out;
}, {});

export const frequentEmojis = frequentShortcodes
  .map(code => {
    const entry = canonicalEntries.find(candidate => candidate.shortcode === code);
    return entry && { ...entry, label: entry.shortcode.replaceAll('_', ' ') };
  })
  .filter(Boolean);

export function frequentEmojiEntries(entries) {
  const entriesByShortcode = {};
  entries.forEach(entry => {
    entriesByShortcode[entry.shortcode] = entry;
  });

  return frequentShortcodes.map(code => entriesByShortcode[code]).filter(Boolean);
}

// Search emoji by shortcode plus localized and English labels/keywords.
export function searchEmojis(query, entries = []) {
  if (!query) { return []; }
  const q = normalizeSearchTerm(query);
  return entries.filter(entry => entry.searchTerms.some(term => term.includes(q)));
}
