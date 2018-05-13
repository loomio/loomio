bowser = require 'bowser'

AppConfig = require 'shared/services/app_config'

angular.module('loomioApp').directive 'browserWarning', ->
  templateUrl: 'generated/components/browser_warning/browser_warning.html'
  controller: ['$scope', ($scope) ->
    $scope.browser  = require 'bowser'
    $scope.siteName = AppConfig.theme.site_name
  ]
