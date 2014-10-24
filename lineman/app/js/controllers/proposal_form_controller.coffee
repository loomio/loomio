angular.module('loomioApp').controller 'ProposalFormController', ($translate, $scope, $modalInstance, proposal, ProposalService) ->
  $scope.proposal = proposal
  console.log(proposal)

  $scope.closingAtPickerIsActive = false

  $scope.showClosingAtPicker = ->
    $scope.closingAtPickerIsActive = true

  $scope.hideClosingAtPicker = ->
    $scope.closingAtPickerIsActive = false

  $scope.toggleClosingAtPicker = ->
    $scope.closingAtPickerIsActive = !$scope.closingAtPickerIsActive

  $scope.submit = ->
    $scope.isDisabled = true
    ProposalService.create($scope.proposal, $scope.saveSuccess, $scope.saveError)

  $scope.dropdownIsOpen = false

  $scope.onSetTime = ->
    console.log($scope.dropdownIsOpen)
    $scope.dropdownIsOpen = false

  $scope.cancel = ->
    $modalInstance.dismiss('cancel');

  $scope.saveSuccess = () ->
    $scope.isDisabled = false
    $modalInstance.close();

  $scope.saveError = (error) ->
    $scope.isDisabled = false
    $scope.errorMessages = error.error_messages

