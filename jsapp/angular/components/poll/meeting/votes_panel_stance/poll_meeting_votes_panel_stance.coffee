angular.module('loomioApp').directive 'pollMeetingVotesPanelStance', ($translate, TranslationService) ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/meeting/votes_panel_stance/poll_meeting_votes_panel_stance.html'
  controller: ($scope) ->
    TranslationService.listenForTranslations $scope

    $scope.participantName = ->
      if $scope.stance.participant()
        $scope.stance.participant().name
      else
        $translate.instant('common.anonymous')
