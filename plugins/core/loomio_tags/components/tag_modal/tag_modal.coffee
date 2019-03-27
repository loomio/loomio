EventBus = require 'shared/services/event_bus.coffee'

angular.module('loomioApp').factory 'TagModal', ->
  templateUrl: 'generated/components/tag_modal/tag_modal.html'
  controller: ['$scope', 'tag', ($scope, tag) ->
    $scope.tag = tag.clone()
    EventBus.listen $scope, 'closeTagForm', $scope.$close
  ]
