angular.module('loomioApp').directive 'navbarUserOptions', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/navbar/navbar_user_options.html'
  replace: true
  controller: ($scope, $rootScope, CurrentUser, $window, RestfulClient) ->
    $scope.currentUser = CurrentUser

    $scope.signOut = ->
      $rootScope.$broadcast 'logout'
      @sessionClient = new RestfulClient('sessions')
      @sessionClient.destroy('').then ->
        $window.location = '/'
