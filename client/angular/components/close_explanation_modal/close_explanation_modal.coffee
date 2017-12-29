Records       = require 'shared/services/records.coffee'
ThreadService = require 'shared/services/thread_service.coffee'

angular.module('loomioApp').factory 'CloseExplanationModal', ->
  templateUrl: 'generated/components/close_explanation_modal/close_explanation_modal.html'
  controller: ['$scope', 'thread', ($scope, thread) ->
    $scope.thread = thread
    $scope.closeThread = ->
      ThreadService.close($scope.thread).then $scope.$close()
  ]
