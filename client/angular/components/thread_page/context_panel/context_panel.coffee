Records        = require 'shared/services/records.coffee'
Session        = require 'shared/services/session.coffee'
EventBus       = require 'shared/services/event_bus.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
ModalService   = require 'shared/services/modal_service.coffee'
ThreadService  = require 'shared/services/thread_service.coffee'
I18n           = require 'shared/services/i18n.coffee'

{ listenForTranslations, listenForReactions } = require 'shared/helpers/listen.coffee'
{ scrollTo }                                  = require 'shared/helpers/window.coffee'

angular.module('loomioApp').directive 'contextPanel', ['$rootScope', ($rootScope) ->
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
      name: 'edit_thread'
      icon: 'mdi-pencil'
      canPerform: -> AbilityService.canEditThread($scope.discussion)
      perform:    -> ModalService.open 'DiscussionModal', discussion: -> $scope.discussion
    ,
      name: 'add_resource'
      icon: 'mdi-attachment'
      canPerform: -> AbilityService.canAdministerDiscussion($scope.discussion)
      perform:    -> ModalService.open 'DocumentModal', doc: ->
        Records.documents.build
          modelId:   $scope.discussion.id
          modelType: 'Discussion'
    ,
      name: 'translate_thread'
      icon: 'mdi-translate'
      canPerform: -> AbilityService.canTranslate($scope.discussion) && !$scope.translation
      perform:    -> $scope.discussion.translate(Session.user().locale)
    ,
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
    ]

    listenForTranslations($scope)
    listenForReactions($scope, $scope.discussion)
  ]
]
