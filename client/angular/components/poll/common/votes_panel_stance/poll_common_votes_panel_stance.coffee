{ listenForTranslations } = require 'shared/helpers/listen'
{ participantName }       = require 'shared/helpers/poll'

angular.module('loomioApp').directive 'pollCommonVotesPanelStance', ->
  scope: {stance: '='}
  template: require('./poll_common_votes_panel_stance.haml')
  controller: ['$scope', ($scope) ->
    listenForTranslations $scope
    $scope.participantName = -> participantName($scope.stance)
  ]
