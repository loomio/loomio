angular.module('loomioApp').config ($routeProvider, $locationProvider) ->
  $locationProvider.html5Mode(true)

  $routeProvider.when '/discussions/:id',
    templateUrl: 'next/templates/discussion'
    controller: 'DiscussionController'
    resolve:
      discussion: ($route, $http) ->
        $http.get("/api/discussions/#{$route.current.params.id}").then (response)->
          response.data
  .when '/',
    templateUrl: 'next/templates/hello'
  .otherwise
    redirectTo: '/'
