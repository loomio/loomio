app = angular.module 'loomioApp', ['ngRoute']

# consume the csrf token from the page
app.config ($httpProvider) ->
  authToken = $("meta[name=\"csrf-token\"]").attr("content")
  $httpProvider.defaults.headers.common["X-CSRF-TOKEN"] = authToken

app.config ($routeProvider, $locationProvider) ->
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


