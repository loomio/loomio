angular.module('loomioApp').directive 'showResultsButton', ->
  templateUrl: 'generated/components/poll/common/show_results_button/show_results_button.html'
  controller: ($scope) ->
    $scope.clicked = false
    $scope.press = ->
      $scope.$emit 'showResults'
      $scope.clicked = true
