{ listenForTranslations } = require 'shared/helpers/listen'
{ participantName }       = require 'shared/helpers/poll'

angular.module('loomioApp').directive 'pollMeetingVotesPanelStance', ->
  scope: {stance: '='}
  template: require('./poll_meeting_votes_panel_stance.haml')
  controller: ['$scope', ($scope) ->
    listenForTranslations $scope
    $scope.participantName = -> participantName($scope.stance)
  ]
