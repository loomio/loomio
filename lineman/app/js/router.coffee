angular.module('loomioApp').config ($routeProvider, $locationProvider) ->
  $locationProvider.html5Mode(true)

  $routeProvider.when '/discussions/:id',
    templateUrl: 'generated/templates/discussion.html'
    controller: 'DiscussionController'
    resolve:
      discussion: ($route, DiscussionService) ->
        DiscussionService.remoteGet($route.current.params.id)
  #.when '/',
    #templateUrl: '/templates/hello'
  .otherwise
    redirectTo: '/'
