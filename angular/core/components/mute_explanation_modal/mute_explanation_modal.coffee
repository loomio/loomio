angular.module('loomioApp').factory 'MuteExplanationModal', ->
  templateUrl: 'generated/components/mute_explanation_modal/mute_explanation_modal.html'
  controller: ($scope, thread, Records, FlashService) ->
    $scope.thread = thread
    $scope.previousVolume = $scope.thread.volume()

    $scope.changeVolume = (volume) ->
      $scope.thread.saveVolume(volume).then ->
        FlashService.success "discussion.volume.#{volume}_message",
          name: $scope.thread.title
        , 'undo', $scope.undo
        $scope.$close()

    $scope.undo = -> $scope.changeVolume($scope.previousVolume)
