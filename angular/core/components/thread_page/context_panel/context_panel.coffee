angular.module('loomioApp').directive 'contextPanel', ->
  scope: {discussion: '='}
  restrict: 'E'
  replace: true
  templateUrl: 'generated/components/thread_page/context_panel/context_panel.html'
  controller: ($scope, $rootScope, $window, $timeout, AbilityService, Session, ModalService, ChangeVolumeForm, DiscussionForm, ThreadService, MoveThreadForm, PrintModal, DeleteThreadForm, RevisionHistoryModal, ScrollService) ->

    $scope.showContextMenu = ->
      AbilityService.canChangeThreadVolume($scope.discussion)

    $scope.canChangeVolume = ->
      Session.user().isMemberOf($scope.discussion.group())

    $scope.openChangeVolumeForm = ->
      ModalService.open ChangeVolumeForm, model: => $scope.discussion

    $scope.canEditThread = ->
      AbilityService.canEditThread($scope.discussion)

    $scope.editThread = ->
      ModalService.open DiscussionForm, discussion: => $scope.discussion

    $scope.scrollToCommentForm = ->
      ScrollService.scrollTo('.comment-form__comment-field')

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

    $scope.canAddComment = ->
      AbilityService.canAddComment($scope.discussion)
