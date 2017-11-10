angular.module('loomioApp').directive 'pollCommonVotesPanelStance', ($translate, TranslationService) ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/common/votes_panel_stance/poll_common_votes_panel_stance.html'
  controller: ($scope) ->
    TranslationService.listenForTranslations $scope

    $scope.participantName = ->
      if $scope.stance.participant()
        $scope.stance.participant().name
      else
        $translate.instant('common.anonymous')
