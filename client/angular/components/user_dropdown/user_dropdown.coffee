AppConfig       = require 'shared/services/app_config.coffee'
Session         = require 'shared/services/session.coffee'
UserHelpService = require 'shared/services/user_help_service.coffee'

{ contactUs } = require 'shared/helpers/window.coffee'

angular.module('loomioApp').directive 'userDropdown', ->
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

    $scope.showHelp = ->
      AppConfig.features.app.help_link

    $scope.contactUs = ->
      contactUs()
