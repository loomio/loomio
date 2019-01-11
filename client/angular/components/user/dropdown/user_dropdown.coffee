AppConfig       = require 'shared/services/app_config'
Session         = require 'shared/services/session'
UserHelpService = require 'shared/services/user_help_service'

angular.module('loomioApp').directive 'userDropdown', ->
  restrict: 'E'
  template: require('./user_dropdown.haml')
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.siteName = AppConfig.theme.site_name

    $scope.user = Session.user()

    $scope.signOut = ->
      Session.signOut()

    $scope.helpLink = ->
      UserHelpService.helpLink()

    $scope.showHelp = ->
      AppConfig.features.app.help_link
  ]
