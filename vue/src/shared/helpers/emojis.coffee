import { each, keys } from 'lodash'
import emojisByCategory from './emoji_table'

emojis = {}

each emojisByCategory, (hash, name) ->
  each hash, (unicode, shortcode) ->
    emojis[shortcode] = unicode

colonsRx = /\:[a-zA-Z0-9-_+]+\:/g

export { emojis, emojisByCategory }

export stripColons = (colons) ->
  if colons && (colons[0] == ':') && (colons[colons.length - 1] == ':')
    colons.substring(1, colons.length - 1)
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

doesSupportEmoji = ->
  context = undefined
  smiley = undefined
  return false if !document.createElement('canvas').getContext
  context = document.createElement('canvas').getContext('2d')
  return false if typeof context.fillText != 'function'
  smile = String.fromCodePoint(0x1F604)
  # :smile: String.fromCharCode(55357) + String.fromCharCode(56835)
  context.textBaseline = 'top'
  context.font = '32px Arial'
  context.fillText smile, 0, 0
  context.getImageData(16, 16, 1, 1).data[0] != 0

###*
# For a UTF-16 (JavaScript's preferred encoding...kinda) surrogate pair,
# return a Unicode codepoint.
###
surrogatePairToCodepoint = (lead, trail) ->
  (lead - 0xD800) * 0x400 + trail - 0xDC00 + 0x10000

export charToCodePoint = (char) ->
  char.codePointAt(0).toString(16)

export srcForEmoji = (hex) ->
  IMAGE_PATH = '/img/openmoji-72x72-color/'
  IMAGE_PATH + hex + '.png'

export imgForEmoji = (hex) ->
  '<img class="emoji" src="' + srcForEmoji(hex) + '">'

export emojiReplaceText = (text) ->
  PATTERN = /([\ud800-\udbff])([\udc00-\udfff])/g
  # PATTERN = /(?:[\u2700-\u27bf]|(?:\ud83c[\udde6-\uddff]){2}|[\ud800-\udbff][\udc00-\udfff])/g
  text.replace PATTERN, (match, p1, p2) ->
    codepoint = surrogatePairToCodepoint(p1.codePointAt(0), p2.codePointAt(0))
    imgForEmoji(codepoint.toString(16))
