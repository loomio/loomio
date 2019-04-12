import Records  from '@/shared/services/records'
import Session  from '@/shared/services/session'
import EventBus from '@/shared/services/event_bus'

# A series of helpers for applying listeners to scope for events, such as an
# emoji being added or a translation being completed
export listenForMentions = ($scope, model) ->
  updateMentionables = ->
    chain = Records.users.collection.chain().find(id: {'$in': $scope.mentionableUserIds})
    chain = chain.where (u) ->
      name = (u.name || "").toLowerCase()
      username = (u.username || "").toLowerCase()
      name.startsWith($scope.q) or username.startsWith($scope.q) or name.includes(" #{$scope.q}")

    $scope.mentionables = _.sortBy(chain.data(), (u) -> (0 - Records.events.find(actorId: u.id).length))

  fetchThenUpdate = _.throttle ->
    Records.users.fetchMentionable($scope.q, model).then (response) ->
      $scope.mentionableUserIds =  _.uniq($scope.mentionableUserIds.concat(_.map(response.users, 'id')))
      updateMentionables()
  ,
    500
  ,
    {leading: true, trailing: true}

  $scope.fetchByNameFragment = (q) ->
    $scope.q = (q || "").toLowerCase()
    if $scope.q.length > 0
      fetchThenUpdate()
      updateMentionables()
    else
      $scope.mentionables = []

  $scope.mentionables = []
  $scope.mentionableUserIds = []
  updateMentionables()



export listenForTranslations = ($scope) ->
  EventBus.listen $scope, 'translationComplete', (e, translatedFields) =>
    return if e.defaultPrevented
    e.preventDefault()
    $scope.translation = translatedFields

export listenForEmoji = ($scope, model, field, $element) ->
  EventBus.listen $scope, 'emojiSelected', (_, emoji) ->
    return unless $textarea = $element.find('textarea')[0]
    caretPosition = $textarea.selectionEnd
    model[field] = "#{(model[field] || '').toString().substring(0, $textarea.selectionEnd)} #{emoji} #{model[field].substring($textarea.selectionEnd)}"
    setTimeout ->
      $textarea.selectionEnd = $textarea.selectionStart = caretPosition + emoji.length + 2
      $textarea.focus()

export listenForReactions = ($scope, model) ->
  EventBus.listen $scope, 'emojiSelected', (_event, emoji) ->
    params =
      reactableType: _.capitalize(model.constructor.singular)
      reactableId:   model.id
      userId:        Session.user().id

    reaction = Records.reactions.find(params)[0] || Records.reactions.build(params)
    reaction.reaction = emoji
    reaction.save()

export listenForLoading = ($scope) ->
  EventBus.listen $scope, 'processing',     -> $scope.isDisabled = true
  EventBus.listen $scope, 'doneProcessing', -> $scope.isDisabled = false
