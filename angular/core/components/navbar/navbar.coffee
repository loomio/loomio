angular.module('loomioApp').directive 'navbar', ($rootScope, ModalService, AuthModal, AbilityService, Session) ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/components/navbar/navbar.html'
  replace: true
  controller: ($scope) ->
    $scope.title = -> Session.pageTitle
    $scope.iconSrc = -> Session.iconSrc

    $scope.isLoggedIn = AbilityService.isLoggedIn
    $scope.toggleSidebar = -> $rootScope.$broadcast 'toggleSidebar'

    $scope.signIn = ->
      ModalService.open AuthModal
