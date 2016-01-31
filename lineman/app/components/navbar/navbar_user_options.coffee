angular.module('loomioApp').directive 'navbarUserOptions', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/navbar/navbar_user_options.html'
  replace: true
  controller: ($scope, $rootScope, CurrentUser, $window, RestfulClient, IntercomService, AppConfig, UserHelpService) ->
    $scope.currentUser = CurrentUser

    $scope.helpLink = ->
      UserHelpService.helpLink()

    $scope.signOut = ->
      $rootScope.$broadcast 'logout'
      @sessionClient = new RestfulClient('sessions')
      @sessionClient.destroy('').then ->
        $window.location = '/'

    $scope.showContactUs = ->
      AppConfig.isLoomioDotOrg

    $scope.contactUs = ->
      IntercomService.contactUs()
