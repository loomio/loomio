Records = require 'shared/services/records.coffee'
Session = require 'shared/services/session.coffee'

module.exports =
  listenForEmoji: ($scope, model, field, $element) ->
    $scope.$on 'emojiSelected', (_, emoji) ->
      return unless $textarea = $element.find('textarea')[0]
      caretPosition = $textarea.selectionEnd
      model[field] = "#{model[field].toString().substring(0, $textarea.selectionEnd)} #{emoji} #{model[field].substring($textarea.selectionEnd)}"
      setTimeout ->
        $textarea.selectionEnd = $textarea.selectionStart = caretPosition + emoji.length + 2
        $textarea.focus()

  listenForReactions: ($scope. model) ->
    $scope.$on 'emojiSelected', (_event, emoji) ->
      params =
        reactableType: _.capitalize(model.constructor.singular)
        reactableId:   model.id
        userId:        Session.user().id

      reaction = Records.reactions.find(params)[0] || Records.reactions.build(params)
      reaction.reaction = emoji
      reaction.save()

  translateEmoji: () ->
