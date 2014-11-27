angular.module('loomioApp').controller 'ProposalFormController', ($scope, $modalInstance, proposal, ProposalService, FormService) ->
  $scope.proposal = proposal
  $scope.closingAtPickerIsActive = false
  
  $scope.successMessage = ->
    if $scope.proposal.isNew?
      'flash.proposal_form.new_proposal'
    else
      'flash.proposal_form.update_proposal'
  $scope.successCallback = ->
    $modalInstance.dismiss('success')

  FormService.applyForm($scope, ProposalService, $scope.proposal)

  $scope.showClosingAtPicker = ->
    $scope.closingAtPickerIsActive = true

  $scope.hideClosingAtPicker = ->
    $scope.closingAtPickerIsActive = false

  $scope.toggleClosingAtPicker = ->
    $scope.closingAtPickerIsActive = !$scope.closingAtPickerIsActive

  $scope.dropdownIsOpen = false

  $scope.onSetTime = ->
    console.log($scope.dropdownIsOpen)
    $scope.dropdownIsOpen = false

  $scope.cancel = ($event) ->
    $event.preventDefault()
    $modalInstance.close('dismiss')

