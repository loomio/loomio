Records        = require 'shared/services/records'
Session        = require 'shared/services/session'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'
ThreadService  = require 'shared/services/thread_service'
LmoUrlService  = require 'shared/services/lmo_url_service'
FlashService   = require 'shared/services/flash_service'
I18n           = require 'shared/services/i18n'

{ listenForTranslations, listenForReactions } = require 'shared/helpers/listen'
{ scrollTo }                                  = require 'shared/helpers/layout'

angular.module('loomioApp').directive 'contextPanel', ['$rootScope', 'clipboard', ($rootScope, clipboard) ->
  scope: {discussion: '='}
  restrict: 'E'
  replace: true
  templateUrl: 'generated/components/thread_page/context_panel/context_panel.html'
  controller: ['$scope', ($scope) ->
    $scope.status = ->
      return 'pinned' if $scope.discussion.pinned

    $scope.statusTitle = ->
      I18n.t "context_panel.thread_status.#{$scope.status()}"

    $scope.showLintel = (bool) ->
      EventBus.broadcast $rootScope, 'showThreadLintel', bool

    $scope.showRevisionHistory = ->
      ModalService.open 'RevisionHistoryModal', model: => $scope.discussion

    $scope.actions = [
      name: 'react'
      canPerform: -> AbilityService.canAddComment($scope.discussion)
    ,
    #   name: 'add_resource'
    #   icon: 'mdi-attachment'
    #   canPerform: -> AbilityService.canAdministerDiscussion($scope.discussion)
    #   perform:    -> ModalService.open 'DocumentModal', doc: ->
    #     Records.documents.build
    #       modelId:   $scope.discussion.id
    #       modelType: 'Discussion'
    # ,
      name: 'translate_thread'
      icon: 'mdi-translate'
      canPerform: -> AbilityService.canTranslate($scope.discussion)
      perform:    -> $scope.discussion.translate(Session.user().locale)
    ,
    #   name: 'copy_url'
    #   icon: 'mdi-link'
    #   canPerform: -> clipboard.supported
    #   perform:    ->
    #     clipboard.copyText(LmoUrlService.discussion($scope.discussion, {}, absolute: true))
    #     FlashService.success("action_dock.discussion_copied")
    # ,
      name: 'add_comment'
      icon: 'mdi-reply'
      canPerform: -> AbilityService.canAddComment($scope.discussion)
      perform:    -> scrollTo('.comment-form textarea')
    ,
      name: 'pin_thread'
      icon: 'mdi-pin'
      canPerform: -> AbilityService.canPinThread($scope.discussion)
      perform:    -> ThreadService.pin($scope.discussion)
    ,
      name: 'unpin_thread'
      icon: 'mdi-pin-off'
      canPerform: -> AbilityService.canUnpinThread($scope.discussion)
      perform:    -> ThreadService.unpin($scope.discussion)
    ,
      name: 'show_history',
      icon: 'mdi-history'
      canPerform: -> $scope.discussion.edited()
      perform:    -> ModalService.open 'RevisionHistoryModal', model: -> $scope.discussion
    ,
      name: 'edit_thread'
      icon: 'mdi-pencil'
      canPerform: -> AbilityService.canEditThread($scope.discussion)
      perform:    -> ModalService.open 'DiscussionEditModal', discussion: -> $scope.discussion
    ]

    listenForTranslations($scope)
    listenForReactions($scope, $scope.discussion)
  ]
]
