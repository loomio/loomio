angular.module('loomioApp').directive 'navbar', ->
  scope: {}
  restrict: 'E'
  templateUrl: 'generated/components/navbar/navbar.html'
  replace: true
  controller: ($scope, $rootScope, $window, Records, ModalService, SignInForm, ThreadQueryService, AppConfig, AbilityService, $mdSidenav, $mdMedia) ->
    $scope.$mdMedia = $mdMedia
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

    $scope.unreadThreadCount = ->
      ThreadQueryService.filterQuery(['show_unread', 'only_threads_in_my_groups'], queryType: 'inbox').length()

    $scope.homePageClicked = ->
      $rootScope.$broadcast 'homePageClicked'

    $scope.openSidebar = ->
      $mdSidenav("left").toggle()

    $scope.signIn = ->
      ModalService.open SignInForm
