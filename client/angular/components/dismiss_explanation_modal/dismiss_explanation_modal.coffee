Records       = require 'shared/services/records.coffee'
ThreadService = require 'shared/services/thread_service.coffee'

angular.module('loomioApp').factory 'DismissExplanationModal', ->
  templateUrl: 'generated/components/dismiss_explanation_modal/dismiss_explanation_modal.html'
  controller: ['$scope', 'thread', ($scope, thread) ->
    $scope.thread = thread

    $scope.dismiss = ->
      ThreadService.dismiss($scope.thread)
      $scope.$close()
  ]
