Records = require 'shared/services/records.coffee'
Session = require 'shared/services/session.coffee'
moment  = require 'moment'

# A series of helpers for applying listeners to scope for events, such as an
# emoji being added or a translation being completed
module.exports =
  listenForMentions: ($scope, model) ->
    $scope.unmentionableIds = [model.authorId, Session.user().id]
    $scope.fetchByNameFragment = (fragment) ->
      Records.memberships.fetchByNameFragment(fragment, model.group().key).then (response) ->
        userIds = _.without(_.pluck(response.users, 'id'), $scope.unmentionableIds...)
        $scope.mentionables = Records.users.find(userIds)

  listenForTranslations: ($scope) ->
    $scope.$on 'translationComplete', (e, translatedFields) =>
      return if e.defaultPrevented
      e.preventDefault()
      $scope.translation = translatedFields

  listenForEmoji: ($scope, model, field, $element) ->
    $scope.$on 'emojiSelected', (_, emoji) ->
      return unless $textarea = $element.find('textarea')[0]
      caretPosition = $textarea.selectionEnd
      model[field] = "#{model[field].toString().substring(0, $textarea.selectionEnd)} #{emoji} #{model[field].substring($textarea.selectionEnd)}"
      setTimeout ->
        $textarea.selectionEnd = $textarea.selectionStart = caretPosition + emoji.length + 2
        $textarea.focus()

  listenForReactions: ($scope, model) ->
    $scope.$on 'emojiSelected', (_event, emoji) ->
      params =
        reactableType: _.capitalize(model.constructor.singular)
        reactableId:   model.id
        userId:        Session.user().id

      reaction = Records.reactions.find(params)[0] || Records.reactions.build(params)
      reaction.reaction = emoji
      reaction.save()

  listenForPaste: ($scope) ->
    $scope.handlePaste = (event) ->
      data = event.clipboardData
      return unless item = _.first _.filter(data.items, (item) -> item.getAsFile())
      event.preventDefault()
      file = new File [item.getAsFile()], data.getData('text/plain') || Date.now(),
        lastModified: moment()
        type:         item.type
      $scope.$broadcast 'filesPasted', [file]

  listenForLoading: ($scope) ->
    $scope.$on 'processing',     -> $scope.isDisabled = true
    $scope.$on 'doneProcessing', -> $scope.isDisabled = false

  listenForEvents: ($scope) ->
    return unless ahoy?

    ahoy.trackClicks()
    ahoy.trackSubmits()
    ahoy.trackChanges()

    # track page views
    $scope.$on 'currentComponent', =>
      ahoy.track '$view',
        page:  window.location.pathname
        url:   window.location.href
        title: document.title

    # track modal views
    $scope.$on 'modalOpened', (_, modal) =>
      ahoy.track 'modalOpened',
        name: modal.templateUrl.match(/(\w+)\.html$/)[1]
