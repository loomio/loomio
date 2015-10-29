angular.module('loomioApp').factory 'ProposalForm', ->
  templateUrl: 'generated/components/proposal_form/proposal_form.html'
  controller: ($scope, $rootScope, proposal, FormService, KeyEventService, ScrollService) ->
    $scope.proposal = proposal.clone()

    $scope.$on 'modal.closing', (event) ->
      FormService.confirmDiscardChanges(event, $scope.proposal)

    actionName = if $scope.proposal.isNew() then 'created' else 'updated'
    $scope.submit = FormService.submit $scope, $scope.proposal,
      flashSuccess: "proposal_form.messages.#{actionName}"
      successCallback: ->
        $rootScope.$broadcast 'setSelectedProposal'
        ScrollService.scrollTo('#current-proposal-card-heading')

    KeyEventService.submitOnEnter $scope
