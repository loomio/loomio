angular.module('loomioApp', ['ngRoute', 'jmdobry.angular-cache', 'ui.bootstrap.datetimepicker']).config ($httpProvider) ->
  alert('hi')
  # consume the csrf token from the page
  authToken = $("meta[name=\"csrf-token\"]").attr("content")
  $httpProvider.defaults.headers.common["X-CSRF-TOKEN"] = authToken

# an example of putting things on the root scope.
#angular.module("app", ["ngResource", "ngRoute"]).run ($rootScope) ->
  #$rootScope.log = (thing) ->
    #console.log(thing);

  #$rootScope.alert = (thing) ->
    #alert(thing);
