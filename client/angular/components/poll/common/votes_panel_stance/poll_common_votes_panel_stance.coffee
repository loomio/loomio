{ listenForTranslations } = require 'shared/helpers/listen'
{ participantName }       = require 'shared/helpers/poll'

angular.module('loomioApp').directive 'pollCommonVotesPanelStance', ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/common/votes_panel_stance/poll_common_votes_panel_stance.html'
  controller: ['$scope', ($scope) ->
    listenForTranslations $scope
    $scope.participantName = -> participantName($scope.stance)
  ]
