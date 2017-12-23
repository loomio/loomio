Records        = require 'shared/services/records.coffee'

angular.module('loomioApp').factory 'MuteExplanationModal', (FlashService, ThreadService) ->
  templateUrl: 'generated/components/mute_explanation_modal/mute_explanation_modal.html'
  controller: ($scope, thread) ->
    $scope.thread = thread
    $scope.previousVolume = $scope.thread.volume()

    $scope.muteThread = ->
      ThreadService.mute($scope.thread).then ->
        $scope.$close()
