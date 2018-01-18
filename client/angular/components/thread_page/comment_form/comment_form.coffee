Session        = require 'shared/services/session.coffee'
Records        = require 'shared/services/records.coffee'
EventBus       = require 'shared/services/event_bus.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
I18n           = require 'shared/services/i18n.coffee'

{ submitForm }    = require 'shared/helpers/form.coffee'
{ submitOnEnter } = require 'shared/helpers/keyboard.coffee'

angular.module('loomioApp').directive 'commentForm', ->
  scope: {eventWindow: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/comment_form/comment_form.html'
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.discussion = $scope.eventWindow.discussion
    $scope.commentHelptext = ->
      helptext = if $scope.discussion.private
        I18n.t 'comment_form.private_privacy_notice', groupName: $scope.comment.group().fullName
      else
        I18n.t 'comment_form.public_privacy_notice'
      helptext.replace('&amp;', '&')
              .replace('&lt;', '<')
              .replace('&gt;', '>')

    $scope.commentPlaceholder = ->
      if $scope.comment.parentId
        I18n.t('comment_form.in_reply_to', name: $scope.comment.parent().author().name)
      else
        I18n.t('comment_form.aria_label')

    EventBus.listen $scope, 'setParentComment', (e, parentComment) ->
      $scope.comment.parentId = parentComment.id

    $scope.init = ->
      $scope.comment = Records.comments.build
        discussionId: $scope.discussion.id
        authorId: Session.user().id

      $scope.submit = submitForm $scope, $scope.comment,
        submitFn: $scope.comment.save
        flashSuccess: ->
          EventBus.emit $scope, 'commentSaved'
          if $scope.comment.isReply()
            'comment_form.messages.replied'
          else
            'comment_form.messages.created'
        flashOptions:
          name: ->
            $scope.comment.parent().authorName() if $scope.comment.isReply()

        successCallback: $scope.init
      submitOnEnter $scope
      EventBus.broadcast $scope, 'reinitializeForm', $scope.comment
    $scope.init()
  ]
