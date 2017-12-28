I18n = require 'shared/services/i18n.coffee'

{ listenForTranslations } = require 'angular/helpers/listen.coffee'

angular.module('loomioApp').directive 'pollCommonVotesPanelStance', ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/common/votes_panel_stance/poll_common_votes_panel_stance.html'
  controller: ($scope) ->
    listenForTranslations $scope

    $scope.participantName = ->
      if $scope.stance.participant()
        $scope.stance.participant().name
      else
        I18n.t('common.anonymous')
