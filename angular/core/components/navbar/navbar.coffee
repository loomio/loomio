angular.module('loomioApp').directive 'navbar', ($rootScope, ModalService, AuthModal, AbilityService, AppConfig) ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/components/navbar/navbar.html'
  replace: true
  controller: ($scope) ->
    $scope.logo = ->
      AppConfig.theme.app_logo_src

    $scope.isLoggedIn = ->
      AbilityService.isLoggedIn()
    $scope.toggleSidebar = -> $rootScope.$broadcast 'toggleSidebar'

    $scope.signIn = ->
      ModalService.open AuthModal
