angular.module('loomioApp').config ($routeProvider, $locationProvider) ->
  $locationProvider.html5Mode(true)

  $routeProvider.when('/discussions/:id',
    templateUrl: 'generated/templates/discussion.html'
    controller: 'DiscussionController'
    resolve:
      discussion: ($route, DiscussionService, RecordStoreService) ->
        promise = DiscussionService.fetchByKey($route.current.params.id)
        if discussion = RecordStoreService.get('discussions', $route.current.params.id)
          discussion
        else
          promise
      currentUser: ($http, UserAuthService, UserModel) ->
        UserAuthService.fetchCurrentUser()
  ).when('/users/sign_in',
    templateUrl: 'generated/templates/login.html'
    controller: 'SessionController'
  ).when('/dashboard',
    templateUrl: 'generated/templates/dashboard.html'
    controller: 'DashboardController'
  ).otherwise
    redirectTo: '/'
