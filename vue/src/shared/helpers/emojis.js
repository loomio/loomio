import { each, keys } from 'lodash';
import emojiUnicode from 'emoji-unicode';
import emojisByCategory from './emoji_table';
import AppConfig      from '@/shared/services/app_config';

const rx = /(?:[\u2700-\u27bf]|(?:\ud83c[\udde6-\uddff]){2}|[\ud800-\udbff][\udc00-\udfff]|[\u0023-\u0039]\ufe0f?\u20e3|\u3299|\u3297|\u303d|\u3030|\u24c2|\ud83c[\udd70-\udd71]|\ud83c[\udd7e-\udd7f]|\ud83c\udd8e|\ud83c[\udd91-\udd9a]|\ud83c[\udde6-\uddff]|[\ud83c[\ude01-\ude02]|\ud83c\ude1a|\ud83c\ude2f|[\ud83c[\ude32-\ude3a]|[\ud83c[\ude50-\ude51]|\u203c|\u2049|[\u25aa-\u25ab]|\u25b6|\u25c0|[\u25fb-\u25fe]|\u00a9|\u00ae|\u2122|\u2139|\ud83c\udc04|[\u2600-\u26FF]|\u2b05|\u2b06|\u2b07|\u2b1b|\u2b1c|\u2b50|\u2b55|\u231a|\u231b|\u2328|\u23cf|[\u23e9-\u23f3]|[\u23f8-\u23fa]|\ud83c\udccf|\u2934|\u2935)/g;

const emojis = {};

each(emojisByCategory, (hash, name) => each(hash, (unicode, shortcode) => emojis[shortcode] = unicode));

const colonsRx = /\:[a-zA-Z0-9-_+]+\:/g;

export { emojis, emojisByCategory };

export var stripColons = function(colons) {
  if (colons && (colons[0] === ':') && (colons[colons.length - 1] === ':')) {
    return colons.substring(1, colons.length - 1);
  } else {
    return colons;
  }
};

export var colonToUnicode = colons => shortCodeToUnicode(stripColons(colons));

export var shortCodeToUnicode = shortcode => emojis[shortcodeCorrect(shortcode)] || `:${shortcodeCorrect(shortcode)}:`;

export var shortcodeCorrect = function(shortcode) {
  const corrections = {
    '+1': 'thumbsup',
    '-1': 'thumbsdown',
    'thinking_face': 'thinking',
    'crossed_fingers': 'fingers_crossed',
    'nerd_face': 'nerd',
    'hugging_face': 'hugging',
    'slightly_frowning_face': 'slight_frown'
  };

  if (corrections[shortcode] != null) {
    return corrections[shortcode];
  } else {
    return shortcode;
  }
};

export var colonsToUnicode = str => str.replace(colonsRx, colonToUnicode);

export var srcForEmoji = function(char, set) {
  char = char.match(rx)[0];
  // prefix = 'https://raw.githubusercontent.com/hfg-gmuend/openmoji/master/color/svg/'
  // suffix = '.svg'
  // prefix + emojiUnicode(char).toUpperCase().replace(' ', '-') + suffix
  const prefix = '/img/emojis/';
  const suffix = '.png';
  return prefix + emojiUnicode(char).toLowerCase().replace(' ', '-') + suffix;
};

export var imgForEmoji = char => '<img class="emoji" src="' + srcForEmoji(char) + '">';

export var emojiSupported = (function() {
  const node = document.createElement('canvas');
  if (!node.getContext || !node.getContext('2d') || (typeof node.getContext('2d').fillText !== 'function')) { return false; }
  const ctx = node.getContext('2d');
  ctx.textBaseline = 'top';
  ctx.font = '32px Arial';
  ctx.fillText('😃', 0, 0);
  return ctx.getImageData(16, 16, 1, 1).data[0] !== 0;
})();

export var emojiReplaceText = function(text) {
  if (emojiSupported) {
    return text;
  } else {
    return text.replace(rx, match => imgForEmoji(match));
  }
};
