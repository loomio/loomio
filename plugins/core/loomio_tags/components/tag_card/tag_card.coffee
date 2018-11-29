AppConfig      = require 'shared/services/app_config.coffee'
Records        = require 'shared/services/records.coffee'
EventBus       = require 'shared/services/event_bus.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
ModalService   = require 'shared/services/modal_service.coffee'

{ applyLoadingFunction } = require 'shared/helpers/apply.coffee'
{ pluginConfigFor }      = require 'shared/helpers/plugin.coffee'

angular.module('loomioApp').directive 'tagCard', ->
  scope: {group: '='}
  templateUrl: 'generated/components/tag_card/tag_card.html'
  controller: ['$scope', ($scope) ->
    $scope.parent = $scope.group.parentOrSelf()

    $scope.init = ->
      Records.tags.fetchByGroup($scope.parent)
    applyLoadingFunction $scope, 'init'
    $scope.init()

    $scope.showTagCard = ->
      $scope.canAdministerGroup() or
      _.some(Records.tags.find(groupId: $scope.parent.id))

    $scope.openTagForm = ->
      ModalService.open 'TagModal', tag: ->
        Records.tags.build
          groupId: $scope.parent.id
          color:   pluginConfigFor('loomio_tags').colors[0]

    $scope.canAdministerGroup = ->
      AbilityService.canAdministerGroup($scope.parent)

    EventBus.listen $scope, 'editTag', (e, tag) ->
      ModalService.open 'TagModal', tag: -> tag
   ]
