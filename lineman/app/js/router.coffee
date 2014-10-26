angular.module('loomioApp').config ($routeProvider, $locationProvider) ->
  $locationProvider.html5Mode(true)

  $routeProvider.when('/discussions/:id',
    templateUrl: 'generated/templates/discussion.html'
    controller: 'DiscussionController'
    resolve:
      discussion: ($route, DiscussionService) ->
        DiscussionService.fetchByKey($route.current.params.id)
      eventSubscription: ($http) ->
        $http.get('/api/v1/faye/subscribe').then (response) ->
          response.data
      currentUser: ($http, UserAuthService, UserModel) ->
        UserAuthService.fetchCurrentUser()
  ).when('/users/login',
    templateUrl: 'generated/templates/login.html'
    controller: 'SessionController'
    resolve: {}
  ).otherwise
    redirectTo: '/'
