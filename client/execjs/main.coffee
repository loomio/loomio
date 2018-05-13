emojione = require 'emojione'

module.exports =
  emojify: (rootUrl, text) ->
    emojione.imagePathPNG = rootUrl + '/img/emojis/'
    emojione.shortnameToImage(text)
