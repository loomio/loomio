angular.module('loomioApp').config ($routeProvider, $locationProvider) ->
  $locationProvider.html5Mode(true)

  $routeProvider.when('/discussions/:id',
    templateUrl: 'generated/templates/discussion_page.html'
    controller: 'DiscussionPageController'
    resolve:
      discussion: ($route, DiscussionService, RecordStoreService) ->
        promise = DiscussionService.fetchByKey($route.current.params.id)
        if discussion = RecordStoreService.get('discussions', $route.current.params.id)
          discussion
        else
          promise
      currentUser: ($http, UserAuthService, UserModel) ->
        UserAuthService.fetchCurrentUser()
  ).when('/groups/:id',
    templateUrl: 'generated/templates/group_page.html',
    controller: 'GroupPageController',
    resolve:
      group: ($route, GroupService) ->
        GroupService.fetchByKey($route.current.params.id)
      currentUser: ($http, UserAuthService, UserModel) ->
        UserAuthService.fetchCurrentUser()
  ).when('/users/sign_in',
    templateUrl: 'generated/templates/login_page.html'
    controller: 'LoginPageController'
  ).when('/dashboard',
    templateUrl: 'generated/templates/dashboard_page.html'
    controller: 'DashboardPageController'
  ).otherwise
    redirectTo: '/'
