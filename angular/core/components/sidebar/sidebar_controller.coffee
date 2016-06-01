angular.module('loomioApp').controller 'SidebarController', ($scope, Session, $rootScope, $window, RestfulClient) ->
  $scope.groups = ->
    Session.user().groups()

  $scope.groupUrl = (group) ->
    name = group.fullName.replace(/[^a-z0-9\-_]+/gi, '-').replace(/-+/g, '-').toLowerCase()
    "/g/#{group.key}/#{name}"

  $scope.signOut = ->
    $rootScope.$broadcast 'logout'
    @sessionClient = new RestfulClient('sessions')
    @sessionClient.destroy('').then ->
    $window.location = '/'