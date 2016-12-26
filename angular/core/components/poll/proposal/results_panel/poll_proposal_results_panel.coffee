angular.module('loomioApp').directive 'pollProposalResultsPanel', (Records) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/proposal/results_panel/poll_proposal_results_panel.html'
  controller: ($scope, TranslationService) ->

    $scope.countFor = (pollOption) ->
      $scope.poll.stanceData[pollOption.name] or 0

    $scope.translationFor = (pollOption) ->
      $scope.translations[pollOption.name]

    TranslationService.eagerTranslate $scope,
      agree:    'poll_proposal_results_panel.agree'
      abstain:  'poll_proposal_results_panel.abstain'
      disagree: 'poll_proposal_results_panel.disagree'
      block:    'poll_proposal_results_panel.block'
