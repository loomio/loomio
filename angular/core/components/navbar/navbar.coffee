angular.module('loomioApp').directive 'navbar', ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/components/navbar/navbar.html'
  replace: true
  controller: ($scope, $rootScope, $window, Records, ModalService, SignInForm, AppConfig, AbilityService) ->
    parser = document.createElement('a')
    parser.href = AppConfig.baseUrl
    $scope.title = "Undefined"
    $scope.officialLoomio = AppConfig.isLoomioDotOrg

    $scope.hostName = parser.hostname

    $scope.isLoggedIn = AbilityService.isLoggedIn

    $scope.$on 'currentComponent', (el, component) ->
      $scope.selected = component.page
    
    $scope.$on 'setTitle', (el, name) ->
      $scope.title = name

    $scope.homePageClicked = ->
      $rootScope.$broadcast 'homePageClicked'

    $scope.toggleSidebar = ->
      $rootScope.$broadcast 'toggleSidebar'

    $scope.signIn = ->
      ModalService.open SignInForm
