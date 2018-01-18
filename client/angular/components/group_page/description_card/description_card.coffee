Records        = require 'shared/services/records.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
ModalService   = require 'shared/services/modal_service.coffee'

{ submitForm } = require 'shared/helpers/form.coffee'

angular.module('loomioApp').directive 'descriptionCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/description_card/description_card.html'
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.actions = [
      name: 'edit_group'
      icon: 'mdi-pencil'
      canPerform: -> AbilityService.canEditGroup($scope.group)
      perform:    -> ModalService.open 'GroupModal', group: -> $scope.group
    ,
      name: 'add_resource'
      icon: 'mdi-attachment'
      canPerform: -> AbilityService.canAdministerGroup($scope.group)
      perform:    -> ModalService.open 'DocumentModal', doc: ->
        Records.documents.build
          modelId:   $scope.group.id
          modelType: 'Group'
    ]
  ]
