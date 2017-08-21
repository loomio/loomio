angular.module('loomioApp').factory 'EmojiService', ($timeout, AppConfig) ->
  new class EmojiService
    source:   AppConfig.emojis.source
    render:   AppConfig.emojis.render
    defaults: AppConfig.emojis.defaults

    listen: (scope, model, field, elem) ->
      scope.$on 'emojiSelected', (_, emoji) ->
        return unless $textarea = elem.find('textarea')[0]
        caretPosition = $textarea.selectionEnd
        model[field] = "#{model[field].substring(0, $textarea.selectionEnd)} #{emoji} #{model[field].substring($textarea.selectionEnd)}"
        $timeout ->
          $textarea.selectionEnd = $textarea.selectionStart = caretPosition + emoji.length + 2
          $textarea.focus()
