AppConfig      = require 'shared/services/app_config.coffee'
EventBus       = require 'shared/services/event_bus.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
ModalService   = require 'shared/services/modal_service.coffee'

angular.module('loomioApp').directive 'navbar', ['$rootScope', ($rootScope) ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/components/navbar/navbar.html'
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.logo = ->
      AppConfig.theme.app_logo_src

    $scope.isLoggedIn = ->
      AbilityService.isLoggedIn()
    $scope.toggleSidebar = -> EventBus.broadcast $rootScope, 'toggleSidebar'

    $scope.signIn = ->
      ModalService.open 'AuthModal'
  ]
]
