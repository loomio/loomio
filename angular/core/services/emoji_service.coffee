angular.module('loomioApp').factory 'EmojiService', ->
  new class EmojiService
    source: window.Loomio.emojis.source
    render: window.Loomio.emojis.render
    defaults: window.Loomio.emojis.defaults
