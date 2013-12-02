angular.module('loomioApp').config ($routeProvider, $locationProvider) ->
  alert('yo wassup')
  $locationProvider.html5Mode(true)

  $routeProvider.when '/discussions/:id',
    templateUrl: 'generated/templates/discussion.html'
    controller: 'DiscussionController'
    resolve:
      discussion: ($route, $http) ->
        $http.get("/api/discussions/#{$route.current.params.id}").then (response)->
          response.data
  #.when '/',
    #templateUrl: '/templates/hello'
  .otherwise
    redirectTo: '/'
