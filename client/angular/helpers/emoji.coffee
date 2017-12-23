module.exports =
  listenForEmoji: ($scope, model, field, $element) ->
    $scope.$on 'emojiSelected', (_, emoji) ->
      return unless $textarea = $element.find('textarea')[0]
      caretPosition = $textarea.selectionEnd
      model[field] = "#{model[field].toString().substring(0, $textarea.selectionEnd)} #{emoji} #{model[field].substring($textarea.selectionEnd)}"
      setTimeout ->
        $textarea.selectionEnd = $textarea.selectionStart = caretPosition + emoji.length + 2
        $textarea.focus()

  translateEmoji: () ->
