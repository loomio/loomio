angular.module('loomioApp').directive 'navbarUserOptions', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/navbar/navbar_user_options.html'
  replace: true
  controller: ($scope, $window, $rootScope, Session, IntercomService, AppConfig, UserHelpService) ->
    $scope.currentUser = Session.user

    $scope.helpLink = ->
      UserHelpService.helpLink()

    $scope.signOut = ->
      Session.logout()

    $scope.showContactUs = ->
      AppConfig.isLoomioDotOrg

    $scope.contactUs = ->
      IntercomService.contactUs()
