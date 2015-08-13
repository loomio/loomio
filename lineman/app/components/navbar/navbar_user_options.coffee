angular.module('loomioApp').directive 'navbarUserOptions', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/navbar/navbar_user_options.html'
  replace: true
  controller: ($scope, CurrentUser, $window, RestfulClient) ->
    $scope.currentUser = CurrentUser

    $scope.signOut = ->
      @sessionClient = new RestfulClient('sessions')
      @sessionClient.destroy('').then ->
        $window.location = '/'
