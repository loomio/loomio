angular.module('loomioApp').directive 'contextPanelDropdown', ($rootScope, $window, $timeout, AbilityService, ModalService, DiscussionModal, ChangeVolumeForm, ThreadService, MoveThreadForm, PrintModal, DeleteThreadForm, RevisionHistoryModal) ->
  scope: {discussion: '='}
  restrict: 'E'
  replace: true
  templateUrl: 'generated/components/thread_page/context_panel_dropdown/context_panel_dropdown.html'
  controller: ($scope) ->

    $scope.canChangeVolume = ->
      AbilityService.canChangeVolume($scope.discussion)

    $scope.openChangeVolumeForm = ->
      ModalService.open ChangeVolumeForm, model: => $scope.discussion

    $scope.canEditThread = ->
      AbilityService.canEditThread($scope.discussion)

    $scope.editThread = ->
      ModalService.open DiscussionModal, discussion: => $scope.discussion

    $scope.canPinThread = ->
      AbilityService.canPinThread($scope.discussion)

    $scope.closeThread = ->
      ThreadService.close($scope.discussion)

    $scope.reopenThread = ->
      ThreadService.reopen($scope.discussion)

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

    $scope.canCloseThread = ->
      AbilityService.canCloseThread($scope.discussion)

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
