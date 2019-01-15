EventBus = require 'shared/services/event_bus.coffee'

angular.module('loomioApp').factory 'TagModal', ->
  template: require('./tag_modal.haml'),
  controller: ['$scope', 'tag', ($scope, tag) ->
    $scope.tag = tag.clone()
    EventBus.listen $scope, 'closeTagForm', $scope.$close
  ]
