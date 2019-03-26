Records        = require 'shared/services/records'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'

angular.module('loomioApp').directive 'subgroupsCard', ['$rootScope', ($rootScope) ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/subgroups_card/subgroups_card.html'
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.show = ->
      $scope.group.isParent()

    Records.groups.fetchByParent($scope.group).then ->
      EventBus.broadcast $rootScope, 'subgroupsLoaded', $scope.group

    $scope.canCreateSubgroups = ->
      AbilityService.canCreateSubgroups($scope.group)

    $scope.startSubgroup = ->
       ModalService.open 'GroupModal', group: -> Records.groups.build(parentId: $scope.group.id)
  ]
]
