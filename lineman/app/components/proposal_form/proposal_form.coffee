angular.module('loomioApp').factory 'ProposalForm', ->
  templateUrl: 'generated/components/proposal_form/proposal_form.html'
  controller: ($scope, $modalInstance, proposal, FormService) ->
    $scope.proposal = proposal

    actionName = if $scope.proposal.isNew() then 'created' else 'updated'
    $scope.submit = FormService.submit $scope, $scope.proposal,
      flashSuccess: "proposal_form.messages.#{actionName}"
