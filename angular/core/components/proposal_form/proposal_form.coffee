angular.module('loomioApp').factory 'ProposalForm', ->
  templateUrl: 'generated/components/proposal_form/proposal_form.html'
  controller: ($scope, $rootScope, proposal, FormService, KeyEventService, ScrollService, EmojiService) ->
    $scope.proposal = proposal.clone()

    actionName = if $scope.proposal.isNew() then 'created' else 'updated'
    $scope.submit = FormService.submit $scope, $scope.proposal,
      flashSuccess: "proposal_form.messages.#{actionName}"
      allowDrafts: true
      successCallback: ->
        $rootScope.$broadcast 'setSelectedProposal'
        ScrollService.scrollTo('#current-proposal-card-heading')

    $scope.descriptionSelector = '.proposal-form__details-field'
    EmojiService.listen $scope, $scope.proposal, 'description', $scope.descriptionSelector

    KeyEventService.submitOnEnter $scope
