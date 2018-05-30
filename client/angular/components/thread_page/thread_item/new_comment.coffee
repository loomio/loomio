Session        = require 'shared/services/session'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
LmoUrlService  = require 'shared/services/lmo_url_service'
FlashService   = require 'shared/services/flash_service'
ModalService   = require 'shared/services/modal_service'

{ listenForTranslations, listenForReactions } = require 'shared/helpers/listen'

angular.module('loomioApp').directive 'newComment', ['$rootScope', 'clipboard', ($rootScope, clipboard) ->
  scope: {event: '=', eventable: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/thread_item/new_comment.html'
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.actions = [
      name: 'react'
      canPerform: -> AbilityService.canAddComment($scope.eventable.discussion())
    ,
      name: 'reply_to_comment'
      icon: 'mdi-reply'
      canPerform: -> AbilityService.canRespondToComment($scope.eventable)
      perform:    -> EventBus.broadcast $rootScope, 'replyToEvent', $scope.event.surfaceOrSelf(), $scope.eventable
    ,
      name: 'edit_comment'
      icon: 'mdi-pencil'
      canPerform: -> AbilityService.canEditComment($scope.eventable)
      perform:    -> ModalService.open 'EditCommentForm', comment: -> $scope.eventable
    ,
      name: 'fork_comment'
      icon: 'mdi-call-split'
      canPerform: -> AbilityService.canForkComment($scope.eventable)
      perform:    ->
        EventBus.broadcast $rootScope, 'toggleSidebar', false
        $scope.event.toggleFromFork()
    ,
      name: 'translate_comment'
      icon: 'mdi-translate'
      canPerform: -> $scope.eventable.body && AbilityService.canTranslate($scope.eventable) && !$scope.translation
      perform:    -> $scope.eventable.translate(Session.user().locale)
    ,
      name: 'copy_url'
      icon: 'mdi-link'
      canPerform: -> clipboard.supported
      perform:    ->
        clipboard.copyText(LmoUrlService.event($scope.event, {}, absolute: true))
        FlashService.success("action_dock.comment_copied")
    ,
      name: 'show_history'
      icon: 'mdi-history'
      canPerform: -> $scope.eventable.edited()
      perform:    -> ModalService.open 'RevisionHistoryModal', model: -> $scope.eventable
    ,
      name: 'delete_comment'
      icon: 'mdi-delete'
      canPerform: -> AbilityService.canDeleteComment($scope.eventable)
      perform:    -> ModalService.open 'ConfirmModal', confirm: ->
        submit: $scope.eventable.destroy
        text:
          title:    'delete_comment_dialog.title'
          helptext: 'delete_comment_dialog.question'
          confirm:  'delete_comment_dialog.confirm'
          flash:    'comment_form.messages.destroyed'
    ]

    listenForReactions($scope, $scope.eventable)
    listenForTranslations($scope)
  ]
]
