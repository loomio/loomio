angular.module('loomioApp').directive 'pollCommonVotesPanelStance', (TranslationService) ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/common/votes_panel_stance/poll_common_votes_panel_stance.html'
  controller: ($scope) ->
    TranslationService.listenForTranslations $scope
