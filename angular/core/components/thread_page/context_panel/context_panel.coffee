angular.module('loomioApp').directive 'contextPanel', ->
  scope: {discussion: '='}
  restrict: 'E'
  replace: true
  templateUrl: 'generated/components/thread_page/context_panel/context_panel.html'
  controller: ($scope, $rootScope, $window, $timeout, AbilityService, Session, ReactionService, ModalService, ChangeVolumeForm, DiscussionEditModal, ThreadService, MoveThreadForm, PrintModal, DeleteThreadForm, RevisionHistoryModal, TranslationService, ScrollService) ->

    $scope.showContextMenu = ->
      AbilityService.canChangeThreadVolume($scope.discussion)

    $scope.canChangeVolume = ->
      Session.user().isMemberOf($scope.discussion.group())

    $scope.openChangeVolumeForm = ->
      ModalService.open ChangeVolumeForm, model: => $scope.discussion

    $scope.canEditThread = ->
      AbilityService.canEditThread($scope.discussion)

    $scope.editThread = ->
      ModalService.open DiscussionEditModal, discussion: => $scope.discussion

    $scope.canPinThread = ->
      AbilityService.canPinThread($scope.discussion)

    $scope.pinThread = ->
      ThreadService.pin($scope.discussion)

    $scope.unpinThread = ->
      ThreadService.unpin($scope.discussion)

    $scope.muteThread = ->
      ThreadService.mute($scope.discussion)

    $scope.unmuteThread = ->
      ThreadService.unmute($scope.discussion)

    $scope.canMoveThread = ->
      AbilityService.canMoveThread($scope.discussion)

    $scope.moveThread = ->
      ModalService.open MoveThreadForm, discussion: => $scope.discussion

    $scope.requestPagePrinted = ->
      $rootScope.$broadcast('toggleSidebar', false)
      if $scope.discussion.allEventsLoaded()
        $timeout -> $window.print()
      else
        ModalService.open PrintModal, preventClose: -> true
        $rootScope.$broadcast 'fetchRecordsForPrint'

    $scope.canDeleteThread = ->
      AbilityService.canDeleteThread($scope.discussion)

    $scope.deleteThread = ->
      ModalService.open DeleteThreadForm, discussion: => $scope.discussion

    $scope.showLintel = (bool) ->
      $rootScope.$broadcast('showThreadLintel', bool)

    $scope.showRevisionHistory = ->
      ModalService.open RevisionHistoryModal, model: => $scope.discussion

    $scope.actions = [
      name: 'react'
      canPerform: -> AbilityService.canAddComment($scope.discussion)
    ,
      name: 'edit_thread'
      icon: 'mdi-pencil'
      canPerform: -> AbilityService.canEditThread($scope.discussion)
      perform:    -> ModalService.open DiscussionEditModal, discussion: -> $scope.discussion
    ,
      name: 'translate_thread'
      icon: 'mdi-translate'
      canPerform: -> AbilityService.canTranslate($scope.discussion) && !$scope.translation
      perform:    -> TranslationService.inline($scope, $scope.discussion)
    ,
      name: 'add_comment'
      icon: 'mdi-reply'
      canPerform: -> AbilityService.canAddComment($scope.discussion)
      perform:    -> ScrollService.scrollTo('.comment-form textarea')
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

    TranslationService.listenForTranslations($scope)
    ReactionService.listenForReactions($scope, $scope.discussion)
