app = angular.module 'loomioApp', ['ngRoute']

# consume the csrf token from the page
app.config ($httpProvider) ->
  authToken = $("meta[name=\"csrf-token\"]").attr("content")
  $httpProvider.defaults.headers.common["X-CSRF-TOKEN"] = authToken

#angular.module("app", ["ngResource", "ngRoute"]).run ($rootScope) ->
  #$rootScope.log = (thing) ->
    #console.log(thing);

  #$rootScope.alert = (thing) ->
    #alert(thing);
