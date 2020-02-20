import { each, keys } from 'lodash'
import emojiUnicode from 'emoji-unicode'
import emojisByCategory from './emoji_table'
import AppConfig      from '@/shared/services/app_config'

rx = /(?:[\u2700-\u27bf]|(?:\ud83c[\udde6-\uddff]){2}|[\ud800-\udbff][\udc00-\udfff]|[\u0023-\u0039]\ufe0f?\u20e3|\u3299|\u3297|\u303d|\u3030|\u24c2|\ud83c[\udd70-\udd71]|\ud83c[\udd7e-\udd7f]|\ud83c\udd8e|\ud83c[\udd91-\udd9a]|\ud83c[\udde6-\uddff]|[\ud83c[\ude01-\ude02]|\ud83c\ude1a|\ud83c\ude2f|[\ud83c[\ude32-\ude3a]|[\ud83c[\ude50-\ude51]|\u203c|\u2049|[\u25aa-\u25ab]|\u25b6|\u25c0|[\u25fb-\u25fe]|\u00a9|\u00ae|\u2122|\u2139|\ud83c\udc04|[\u2600-\u26FF]|\u2b05|\u2b06|\u2b07|\u2b1b|\u2b1c|\u2b50|\u2b55|\u231a|\u231b|\u2328|\u23cf|[\u23e9-\u23f3]|[\u23f8-\u23fa]|\ud83c\udccf|\u2934|\u2935|[\u2190-\u21ff])/g

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

export srcForEmoji = (char, set) ->
  char = char.match(rx)[0]
  switch set
    when 'openmoji-svg'
      prefix = 'https://raw.githubusercontent.com/hfg-gmuend/openmoji/master/color/svg/'
      suffix = '.svg'
      prefix + emojiUnicode(char).toUpperCase().replace(' ', '-') + suffix
    when 'openmoji-png'
      prefix = 'https://raw.githubusercontent.com/hfg-gmuend/openmoji/master/color/72x72/'
      suffix = '.png'
      prefix + emojiUnicode(char).toUpperCase().replace(' ', '-') + suffix
    when 'twemoji-svg'
      prefix = 'https://twemoji.maxcdn.com/v/latest/svg/'
      suffix = '.svg'
      prefix + emojiUnicode(char).toLowerCase().replace(' ', '-') + suffix
    else
      prefix = 'https://twemoji.maxcdn.com/v/latest/72x72/'
      suffix = '.png'
      prefix + emojiUnicode(char).toLowerCase().replace(' ', '-') + suffix

export imgForEmoji = (char) ->
  '<img class="emoji" src="' + srcForEmoji(char) + '">'

export emojiSupported = do ->
  node = document.createElement('canvas')
  return false if !node.getContext or !node.getContext('2d') or typeof node.getContext('2d').fillText != 'function'
  ctx = node.getContext('2d')
  ctx.textBaseline = 'top'
  ctx.font = '32px Arial'
  ctx.fillText '😃', 0, 0
  ctx.getImageData(16, 16, 1, 1).data[0] != 0

export replaceEmojis = ->
  !emojiSupported && AppConfig.features.app.env != 'test'

export emojiReplaceText = (text) ->
  if replaceEmojis()
    text
  else
    text.replace rx, (match) -> imgForEmoji(match)
