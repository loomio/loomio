angular.module('loomioApp').controller 'ProposalFormController', ($scope, $modalInstance, proposal, FlashService) ->
  $scope.proposal = proposal

  $scope.closeDateTimePicker = ->
    $scope.dropdownIsOpen = false

  onCreateSuccess = (records) ->
    $modalInstance.close()
    proposal = records.proposals[0]
    FlashService.success 'proposal_form.messages.created'

  onUpdateSuccess = (records) ->
    FlashService.success 'proposal_form.messages.updated'
    $modalInstance.close()

  $scope.submit = ->
    if proposal.isNew()
      proposal.save().then onCreateSuccess
    else
      proposal.save().then onUpdateSuccess

  $scope.cancel = ->
    $modalInstance.dismiss()
