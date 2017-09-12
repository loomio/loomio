angular.module('loomioApp').directive 'navbar', ($rootScope, ModalService, AuthModal, AbilityService, Session, AppConfig) ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/components/navbar/navbar.html'
  replace: true
  controller: ($scope) ->
    $scope.title = -> Session.pageTitle

    $scope.bgStyle = ->
      if Session.showLogo
        {'background-image': "url(#{AppConfig.theme.logo_src})"}
      else
        {}

    $scope.isLoggedIn = AbilityService.isLoggedIn
    $scope.toggleSidebar = -> $rootScope.$broadcast 'toggleSidebar'

    $scope.signIn = ->
      ModalService.open AuthModal
