angular.module('loomioApp').controller 'SidebarController', ($scope, UserAuthService) ->

  $scope.inboxPinned = ->
    UserAuthService.inboxPinned
