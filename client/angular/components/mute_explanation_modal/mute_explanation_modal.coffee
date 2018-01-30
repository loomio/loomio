Records       = require 'shared/services/records.coffee'
FlashService  = require 'shared/services/flash_service.coffee'
ThreadService = require 'shared/services/thread_service.coffee'

angular.module('loomioApp').factory 'MuteExplanationModal', ->
  templateUrl: 'generated/components/mute_explanation_modal/mute_explanation_modal.html'
  controller: ['$scope', 'thread', ($scope, thread) ->
    $scope.thread = thread
    $scope.previousVolume = $scope.thread.volume()

    $scope.muteThread = ->
      ThreadService.mute($scope.thread).then ->
        $scope.$close()
  ]
