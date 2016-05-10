angular.module('loomioApp').directive 'pieWithPosition', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/components/pie_with_position/pie_with_position.html'
  replace: true
  controller: ($scope, Session) ->

    $scope.lastVoteByCurrentUser = (proposal) ->
      proposal.lastVoteByUser(Session.user())
