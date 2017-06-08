angular.module('loomioApp').directive 'installSlackTableau', (Session) ->
  templateUrl: 'generated/components/install_slack/tableau/install_slack_tableau.html'
  controller: ($scope) ->
    $scope.group = ->
      Session.currentGroup
