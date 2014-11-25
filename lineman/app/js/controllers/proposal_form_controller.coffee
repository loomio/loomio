angular.module('loomioApp').controller 'ProposalFormController', ($scope, $modalInstance, proposal, ProposalService) ->
  $scope.proposal = proposal
  $scope.proposalHasVotes = proposal.votes()?

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

  $scope.cancel = ($event) ->
    $event.preventDefault()
    $modalInstance.dismiss('cancel');

  $scope.isUneditable = ->
    $scope.isDisabled or $scope.proposalHasVotes

  $scope.saveSuccess = () ->
    $scope.isDisabled = false
    $modalInstance.close();

  $scope.saveError = (error) ->
    $scope.isDisabled = false
    $scope.errorMessages = error.error_messages

