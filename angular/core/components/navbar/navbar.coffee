angular.module('loomioApp').directive 'navbar', ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/components/navbar/navbar.html'
  replace: true
  controller: ($scope, $rootScope, $window, Records, ModalService, SignInForm, AppConfig, AbilityService) ->
    parser = document.createElement('a')
    parser.href = AppConfig.baseUrl
    $scope.showNavbar = true

    $scope.$on 'toggleNavbar', (event, show) ->
      $scope.showNavbar = show

    $scope.hostName = parser.hostname

    $scope.isLoggedIn = AbilityService.isLoggedIn

    $scope.toggleSidebar = ->
      $rootScope.$broadcast 'toggleSidebar'


    $scope.signIn = ->
      ModalService.open SignInForm
