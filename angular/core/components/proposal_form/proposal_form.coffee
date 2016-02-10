angular.module('loomioApp').factory 'ProposalForm', ->
  templateUrl: 'generated/components/proposal_form/proposal_form.html'
  controller: ($scope, $rootScope, proposal, FormService, KeyEventService, ScrollService) ->
    $scope.proposal = proposal.clone()

    actionName = if $scope.proposal.isNew() then 'created' else 'updated'
    $scope.submit = FormService.submit $scope, $scope.proposal,
      flashSuccess: "proposal_form.messages.#{actionName}"
      allowDrafts: true
      successCallback: ->
        $rootScope.$broadcast 'setSelectedProposal'
        ScrollService.scrollTo('#current-proposal-card-heading')

    $scope.$on 'emojiSelected', (event, emoji) ->
      $scope.proposal.description = $scope.proposal.description.trimRight() + " #{emoji} "

    KeyEventService.submitOnEnter $scope
