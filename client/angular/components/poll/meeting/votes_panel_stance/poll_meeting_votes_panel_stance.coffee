{ listenForTranslations } = require 'angular/helpers/listen.coffee'

angular.module('loomioApp').directive 'pollMeetingVotesPanelStance', ($translate) ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/meeting/votes_panel_stance/poll_meeting_votes_panel_stance.html'
  controller: ($scope) ->
    listenForTranslations $scope

    $scope.participantName = ->
      if $scope.stance.participant()
        $scope.stance.participant().name
      else
        $translate.instant('common.anonymous')
