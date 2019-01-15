AppConfig   = require 'shared/services/app_config'
Records     = require 'shared/services/records'
EventBus    = require 'shared/services/event_bus'
AuthService = require 'shared/services/auth_service'

angular.module('loomioApp').factory 'AuthModal', ->
  template: require('./auth_modal.haml')
  controller: ['$scope', 'preventClose', ($scope, preventClose) ->
    $scope.siteName = AppConfig.theme.site_name
    $scope.user = AuthService.applyEmailStatus Records.users.build(), AppConfig.pendingIdentity
    $scope.preventClose = preventClose
    EventBus.listen $scope, 'signedIn', $scope.$close

    $scope.back = -> $scope.user.emailStatus = null

    $scope.showBackButton = ->
      $scope.user.emailStatus and
      !$scope.user.sentLoginLink and
      !$scope.user.sentPasswordLink
  ]
