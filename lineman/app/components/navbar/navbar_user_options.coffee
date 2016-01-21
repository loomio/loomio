angular.module('loomioApp').directive 'navbarUserOptions', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/navbar/navbar_user_options.html'
  replace: true
  controller: ($scope, $rootScope, CurrentUser, $window, RestfulClient, IntercomService, AppConfig) ->
    $scope.currentUser = CurrentUser

    $scope.helpLink = ->
      if _.contains(['es', 'an', 'ca', 'gl'], CurrentUser.locale)
        'https://loomio.gitbooks.io/manual/content/es/index.html'
      else
        'https://help.loomio.org'

    $scope.signOut = ->
      $rootScope.$broadcast 'logout'
      @sessionClient = new RestfulClient('sessions')
      @sessionClient.destroy('').then ->
        $window.location = '/'

    $scope.showContactUs = ->
      AppConfig.isLoomioDotOrg

    $scope.contactUs = ->
      IntercomService.contactUs()
