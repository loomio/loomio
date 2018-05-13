I18n = require 'shared/services/i18n'

{ listenForTranslations } = require 'shared/helpers/listen'

angular.module('loomioApp').directive 'pollCommonVotesPanelStance', ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/common/votes_panel_stance/poll_common_votes_panel_stance.html'
  controller: ['$scope', ($scope) ->
    listenForTranslations $scope

    $scope.participantName = ->
      if $scope.stance.participant()
        $scope.stance.participant().name
      else
        I18n.t('common.anonymous')
  ]
