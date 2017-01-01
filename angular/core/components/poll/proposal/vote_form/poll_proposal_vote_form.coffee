angular.module('loomioApp').factory 'PollProposalVoteForm', ->
  templateUrl: 'generated/components/poll/proposal/vote_form/poll_proposal_vote_form.html'
  controller: ($scope, stance, FormService, TranslationService, KeyEventService) ->
    $scope.stance = stance.clone()

    actionName = if $scope.stance.isNew() then 'created' else 'updated'

    $scope.submit = FormService.submit $scope, $scope.stance,
      flashSuccess: "poll_proposal_vote_form.messages.#{actionName}"
      draftFields: ['reason']

    TranslationService.eagerTranslate
      detailsPlaceholder: 'poll_common.statement_placeholder'

    KeyEventService.submitOnEnter($scope)
