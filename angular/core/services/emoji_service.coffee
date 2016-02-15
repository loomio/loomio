angular.module('loomioApp').factory 'EmojiService', ->
  new class EmojiService
    source: window.Loomio.emojis.source
    render: window.Loomio.emojis.render
    defaults: window.Loomio.emojis.defaults

    listen: (scope, model, field, target) ->
      scope.$on 'emojiSelected', (event, emoji, selector) ->
        model[field] = "#{model[field].trimRight()} #{emoji}" if selector == target
