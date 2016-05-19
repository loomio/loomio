angular.module('loomioApp').directive 'sidebar', ->
  # scope: {}
  restrict: 'E'
  templateUrl: 'generated/components/sidebar/sidebar.html'
  replace: true
  controller: ($scope, CurrentUser, $rootScope, $window, RestfulClient) ->

    $scope.logHello = ->
      console.log("Hello")

    $scope.groups = ->
      CurrentUser.groups()

    $scope.groupUrl = (group) ->
      name = group.fullName.replace(/[^a-z0-9\-_]+/gi, '-').replace(/-+/g, '-').toLowerCase()
      "/g/#{group.key}/#{name}"

    $scope.signOut = ->
      $rootScope.$broadcast 'logout'
      @sessionClient = new RestfulClient('sessions')
      @sessionClient.destroy('').then ->
      $window.location = '/'
