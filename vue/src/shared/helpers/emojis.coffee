import { each, keys } from 'lodash';
import emojisByCategory from './emoji_table';

emojis = {}

each emojisByCategory, (hash, name) ->
  each hash, (unicode, shortcode) ->
    emojis[shortcode] = unicode

colonsRx = /\:[a-zA-Z0-9-_+]+\:/g

export { emojis, emojisByCategory }

export stripColons = (colons) ->
  if (colons[0] == ':') && (colons[colons.length-1] == ':')
    colons.substring(1, colons.length-1)
  else
    colons

export colonToUnicode = (colons) ->
  shortCodeToUnicode(stripColons(colons))

export shortCodeToUnicode = (shortcode) ->
  emojis[shortcodeCorrect(shortcode)] or ":#{shortcodeCorrect(shortcode)}:"

export shortcodeCorrect = (shortcode) ->
  corrections =
    '+1': 'thumbsup'
    '-1': 'thumbsdown'
    'slight_smile': 'smile'
    'thinking_face': 'thinking'
    'crossed_fingers': 'fingers_crossed'
    'nerd_face': 'nerd'
    'hugging_face': 'hugging'
    'slightly_frowning_face': 'slight_frown'

  if corrections[shortcode]?
    corrections[shortcode]
  else
    shortcode

export colonsToUnicode = (str) ->
  str.replace colonsRx, colonToUnicode
