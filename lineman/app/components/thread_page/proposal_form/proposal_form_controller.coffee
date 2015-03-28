angular.module('loomioApp').controller 'ProposalFormController', ($scope, $modalInstance, proposal, FlashService) ->
  $scope.proposal = proposal

  $scope.closeDateTimePicker = ->
    $scope.dropdownIsOpen = false

  onCreateSuccess = (records) ->
    $modalInstance.close()
    FlashService.good 'proposal_form.messages.created'

  onUpdateSuccess = (records) ->
    $modalInstance.close()
    FlashService.good 'proposal_form.messages.updated'

  $scope.submit = ->
    if proposal.isNew()
      proposal.save().then onCreateSuccess
    else
      proposal.save().then onUpdateSuccess

  $scope.cancel = ->
    $modalInstance.dismiss()
