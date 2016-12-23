angular.module('loomioApp').factory 'PollProposalVoteForm', ->
  templateUrl: 'generated/components/poll/proposal/vote_form/poll_proposal_vote_form.html'
  controller: ($scope, $translate, stance, FormService) ->
    $scope.stance = stance.clone()
    console.log $scope.stance

    actionName = if $scope.stance.isNew() then 'created' else 'updated'

    $scope.submit = FormService.submit $scope, $scope.stance,
      flashSuccess: "poll_proposal_form.messages.#{actionName}"
      draftFields: ['title', 'details']

    $scope.translations =
      detailsPlaceholder: $translate.instant 'poll_proposal_vote_form.statement_placeholder'
