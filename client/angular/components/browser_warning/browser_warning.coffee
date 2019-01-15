bowser = require 'bowser'

AppConfig = require 'shared/services/app_config'

angular.module('loomioApp').directive 'browserWarning', ->
  template: require('./browser_warning.haml')
  controller: ['$scope', ($scope) ->
    $scope.browser  = require 'bowser'
    $scope.siteName = AppConfig.theme.site_name
  ]
