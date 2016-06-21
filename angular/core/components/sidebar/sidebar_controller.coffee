angular.module('loomioApp').controller 'SidebarController', ($scope, Session, $rootScope, $window, RestfulClient, $mdMedia, ThreadQueryService, UserHelpService, AppConfig, IntercomService) ->

  $scope.groups = ->
    Session.user().groups()

  $scope.groupUrl = (group) ->
    name = group.fullName.replace(/[^a-z0-9\-_]+/gi, '-').replace(/-+/g, '-').toLowerCase()
    "/g/#{group.key}/#{name}"

  $scope.signOut = ->
    $rootScope.$broadcast 'logout'
    @sessionClient = new RestfulClient('sessions')
    @sessionClient.destroy('').then ->
    $window.location = '/'

  $scope.helpLink = ->
    UserHelpService.helpLink()

  $scope.smallScreen = ->
    $mdMedia("max-width: 1279px")

  $scope.unreadThreadCount = ->
    ThreadQueryService.filterQuery(['show_unread', 'only_threads_in_my_groups'], queryType: 'inbox').length()

  $scope.showContactUs = ->
    AppConfig.isLoomioDotOrg

  $scope.contactUs = ->
    IntercomService.contactUs()
