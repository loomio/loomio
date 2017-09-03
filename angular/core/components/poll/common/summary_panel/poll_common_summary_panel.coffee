angular.module('loomioApp').directive 'pollCommonSummaryPanel', (TranslationService, ReactionService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/summary_panel/poll_common_summary_panel.html'
  controller: ($scope) ->
    TranslationService.listenForTranslations($scope)
    ReactionService.listenForReactions($scope, $scope.poll)
