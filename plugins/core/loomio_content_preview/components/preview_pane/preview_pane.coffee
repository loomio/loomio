EventBus = require 'shared/services/event_bus.coffee'

angular.module('loomioApp').directive 'previewPane', ->
  scope: {comment: '=?', poll: '=?', discussion: '=?', outcome: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/preview_pane/preview_pane.html'
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.model = $scope.comment || $scope.poll || $scope.discussion || $scope.outcome
    $scope.type  = $scope.model.constructor.singular if $scope.model

    if $scope.comment
      EventBus.listen $scope, 'reinitializeForm', (event, comment) -> $scope.model = comment
  ]
