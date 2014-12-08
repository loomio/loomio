angular.module('loomioApp').controller 'ProposalFormController', ($scope, $modalInstance, proposal, FlashService) ->
  $scope.proposal = proposal

  $scope.closeDateTimePicker = ->
    $scope.dropdownIsOpen = false

  $scope.submit = ->
    $scope.isDisabled = true
    proposal.save().then (records) ->
      FlashService.success 'proposal_form.messages.proposal_created'
      $modalInstance.close()
    , (errors) ->
      $scope.formErrors = errors
      $scope.isDisabled = false

  $scope.cancel = ->
    $modalInstance.dismiss()
