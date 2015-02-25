angular.module('loomioApp').directive 'inbox', ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/modules/inbox/inbox.html'
  replace: true
  controller: ($scope, Records, UserAuthService) ->
    $scope.currentUser = UserAuthService.currentUser
    Records.discussions.fetchInbox()
