angular.module('loomioApp').directive 'navbar', ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/components/navbar/navbar.html'
  replace: true
  controller: ($scope, $rootScope, $window, Records, ThreadQueryService, AppConfig, AbilityService) ->
    parser = document.createElement('a')
    parser.href = AppConfig.baseUrl

    $scope.officialLoomio = AppConfig.isLoomioDotOrg

    $scope.hostName = parser.hostname

    $scope.isLoggedIn = ->
      AbilityService.isLoggedIn()

    $scope.$on 'currentComponent', (el, component) ->
      $scope.selected = component.page

    $scope.unreadThreadCount = ->
      ThreadQueryService.filterQuery(['show_unread', 'only_threads_in_my_groups'], queryType: 'inbox').length()

    $scope.homePageClicked = ->
      $rootScope.$broadcast 'homePageClicked'

    $scope.goToSignIn = ->
      $window.location = '/users/sign_in'
