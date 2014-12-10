angular.module('loomioApp').controller 'InboxController', ($scope, Records, UserAuthService) ->
  $scope.currentUser = UserAuthService.currentUser

  Records.discussions.fetchInbox()
