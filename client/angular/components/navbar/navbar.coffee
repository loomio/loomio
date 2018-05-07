AppConfig      = require 'shared/services/app_config'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'

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
