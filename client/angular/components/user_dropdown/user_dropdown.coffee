AppConfig       = require 'shared/services/app_config.coffee'
Session         = require 'shared/services/session.coffee'
UserHelpService = require 'shared/services/user_help_service.coffee'

angular.module('loomioApp').directive 'userDropdown', (IntercomService) ->
  restrict: 'E'
  templateUrl: 'generated/components/user_dropdown/user_dropdown.html'
  replace: true
  controller: ($scope) ->
    $scope.siteName = AppConfig.theme.site_name

    $scope.user = Session.user()

    $scope.signOut = ->
      Session.signOut()

    $scope.helpLink = ->
      UserHelpService.helpLink()

    $scope.showContactUs = ->
      IntercomService.available()

    $scope.showHelp = ->
      AppConfig.features.app.help_link

    $scope.contactUs = ->
      IntercomService.contactUs()
