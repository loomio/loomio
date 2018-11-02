Records  = require 'shared/services/records'
Session  = require 'shared/services/session'
EventBus = require 'shared/services/event_bus'

# A series of helpers for applying listeners to scope for events, such as an
# emoji being added or a translation being completed
module.exports =
  listenForMentions: ($scope, model) ->
    $scope.mentionables = []
    $scope.mentionableUserIds = []
    $scope.fetchByNameFragment = (q) ->
      if q.length > 0
        Records.users.fetchMentionable(q, model).then (response) ->
          $scope.mentionableUserIds =  _.uniq($scope.mentionableUserIds.concat(_.pluck(response.users, 'id')))
          chain = Records.users.collection.chain().find(id: {'$in': $scope.mentionableUserIds})
          chain = chain.where (u) ->
            q = q.toLowerCase()
            u.name.toLowerCase().startsWith(q) or
            u.username.toLowerCase().startsWith(q) or
            u.name.toLowerCase().includes(" #{q}")
          $scope.mentionables = chain.data()
      else
        $scope.mentionables = []

  listenForTranslations: ($scope) ->
    EventBus.listen $scope, 'translationComplete', (e, translatedFields) =>
      return if e.defaultPrevented
      e.preventDefault()
      $scope.translation = translatedFields

  listenForEmoji: ($scope, model, field, $element) ->
    EventBus.listen $scope, 'emojiSelected', (_, emoji) ->
      return unless $textarea = $element.find('textarea')[0]
      caretPosition = $textarea.selectionEnd
      model[field] = "#{(model[field] || '').toString().substring(0, $textarea.selectionEnd)} #{emoji} #{model[field].substring($textarea.selectionEnd)}"
      setTimeout ->
        $textarea.selectionEnd = $textarea.selectionStart = caretPosition + emoji.length + 2
        $textarea.focus()

  listenForReactions: ($scope, model) ->
    EventBus.listen $scope, 'emojiSelected', (_event, emoji) ->
      params =
        reactableType: _.capitalize(model.constructor.singular)
        reactableId:   model.id
        userId:        Session.user().id

      reaction = Records.reactions.find(params)[0] || Records.reactions.build(params)
      reaction.reaction = emoji
      reaction.save()

  listenForLoading: ($scope) ->
    EventBus.listen $scope, 'processing',     -> $scope.isDisabled = true
    EventBus.listen $scope, 'doneProcessing', -> $scope.isDisabled = false
