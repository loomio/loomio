I18n = require 'shared/services/i18n.coffee'

{ listenForTranslations } = require 'shared/helpers/listen.coffee'

angular.module('loomioApp').directive 'pollMeetingVotesPanelStance', ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/meeting/votes_panel_stance/poll_meeting_votes_panel_stance.html'
  controller: ['$scope', ($scope) ->
    listenForTranslations $scope

    $scope.participantName = ->
      if $scope.stance.participant()
        $scope.stance.participant().name
      else
        I18n.t('common.anonymous')
  ]
