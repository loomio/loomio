angular.module('loomioApp').controller 'GroupOptionsDropdownController', ($scope, GroupService, UserAuthService) ->

  $scope.canEditGroup = ->
    UserAuthService.currentUser.isAdminOf($scope.group)
