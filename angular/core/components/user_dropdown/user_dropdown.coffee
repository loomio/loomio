angular.module('loomioApp').directive 'userDropdown', (AppConfig, Session, UserHelpService, IntercomService) ->
  restrict: 'E'
  templateUrl: 'generated/components/user_dropdown/user_dropdown.html'
  replace: true
  controller: ($scope) ->
    $scope.siteName = AppConfig.theme.site_name
    
    $scope.user = Session.user()

    $scope.signOut = ->
      Session.logout()

    $scope.helpLink = ->
      UserHelpService.helpLink()

    $scope.showContactUs = ->
      IntercomService.available()

    $scope.showHelp = ->
      AppConfig.features.help_link

    $scope.contactUs = ->
      IntercomService.contactUs()
