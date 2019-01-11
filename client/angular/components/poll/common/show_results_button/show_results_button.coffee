EventBus = require 'shared/services/event_bus'

angular.module('loomioApp').directive 'showResultsButton', ->
  template: require('./show_results_button.haml')
  controller: ['$scope', ($scope) ->
    $scope.clicked = false
    $scope.press = ->
      EventBus.emit $scope, 'showResults'
      $scope.clicked = true
  ]
