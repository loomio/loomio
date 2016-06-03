angular.module('loomioApp').directive 'navbarUserOptions', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/navbar/navbar_user_options.html'
  replace: true
  controller: ($scope, $window, $rootScope, Session, Records, IntercomService, AppConfig, UserHelpService) ->
    $scope.currentUser = Session.user

    $scope.helpLink = ->
      UserHelpService.helpLink()

    $scope.signOut = ->
      Records.sessions.remote.destroy('').then -> $window.location.href = '/'

    $scope.showContactUs = ->
      AppConfig.isLoomioDotOrg

    $scope.contactUs = ->
      IntercomService.contactUs()
