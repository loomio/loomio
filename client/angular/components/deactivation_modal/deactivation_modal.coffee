AbilityService = require 'shared/services/ability_service.coffee'
ModalService   = require 'shared/services/modal_service.coffee'

angular.module('loomioApp').factory 'DeactivationModal', ->
  templateUrl: 'generated/components/deactivation_modal/deactivation_modal.html'
  controller: ($scope) ->

    $scope.submit = ->
      if AbilityService.canDeactivateUser()
        ModalService.open 'DeactivateUserForm'
      else
        ModalService.open 'OnlyCoordinatorModal'
