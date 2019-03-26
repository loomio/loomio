EventBus = require 'shared/services/event_bus'

angular.module('loomioApp').directive 'showResultsButton', ->
  templateUrl: 'generated/components/poll/common/show_results_button/show_results_button.html'
  controller: ['$scope', ($scope) ->
    $scope.clicked = false
    $scope.press = ->
      EventBus.emit $scope, 'showResults'
      $scope.clicked = true
  ]
