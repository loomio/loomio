angular.module('loomioApp').factory 'DeactivationModal', ->
  templateUrl: 'generated/components/deactivation_modal/deactivation_modal.html'
  controller: ($scope, AbilityService, ModalService, DeactivateUserForm, OnlyCoordinatorModal) ->

    $scope.submit = ->
      if AbilityService.canDeactivateUser()
        ModalService.open DeactivateUserForm
      else
        ModalService.open OnlyCoordinatorModal
