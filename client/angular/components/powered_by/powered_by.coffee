AppConfig = require 'shared/services/app_config'
angular.module('loomioApp').directive 'poweredBy', ->
  scope: {}
  restrict: 'E'
  template: require('./powered_by.haml')
  controller: ['$scope', ($scope) ->
    $scope.privacyUrl   = AppConfig.theme.privacy_url
    $scope.termsUrl     = AppConfig.theme.terms_url
    $scope.frontPageUrl = AppConfig.baseUrl + "?frontpage"
    $scope.showFrontPage = AppConfig.baseUrl != "https://www.loomio.org/"
  ]
