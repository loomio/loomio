angular.module('loomioApp').factory 'MuteExplanationModal', ->
  templateUrl: 'generated/components/mute_explanation_modal/mute_explanation_modal.html'
  controller: ($scope, thread, Records, FlashService, ThreadService) ->
    $scope.thread = thread
    $scope.previousVolume = $scope.thread.volume()

    $scope.muteThread = ->
      ThreadService.mute($scope.thread).then ->
        $scope.$close()
