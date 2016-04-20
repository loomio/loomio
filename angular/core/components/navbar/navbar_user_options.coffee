angular.module('loomioApp').directive 'navbarUserOptions', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/navbar/navbar_user_options.html'
  replace: true
  controller: ($scope, $rootScope, User, Records, IntercomService, AppConfig, UserHelpService) ->
    $scope.currentUser = User.current

    $scope.helpLink = ->
      UserHelpService.helpLink()

    $scope.signOut = ->
      Records.sessions.remote.destroy('').then -> User.logout()

    $scope.showContactUs = ->
      AppConfig.isLoomioDotOrg

    $scope.contactUs = ->
      IntercomService.contactUs()
