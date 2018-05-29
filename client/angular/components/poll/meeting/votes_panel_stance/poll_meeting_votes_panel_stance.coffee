{ listenForTranslations } = require 'shared/helpers/listen'
{ participantName }       = require 'shared/helpers/poll'

angular.module('loomioApp').directive 'pollMeetingVotesPanelStance', ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/meeting/votes_panel_stance/poll_meeting_votes_panel_stance.html'
  controller: ['$scope', ($scope) ->
    listenForTranslations $scope
    $scope.participantName = -> participantName($scope.stance)
  ]
