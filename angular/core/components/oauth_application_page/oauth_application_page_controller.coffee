angular.module('loomioApp').controller 'OauthApplicationPageController', ($scope, $routeParams, $rootScope, Records) ->

  @init = (application) =>
    if application and !@application?
      @application = application
      $rootScope.$broadcast 'currentComponent', { page: 'oauthApplicationPage'}

  @init Records.oauthApplications.find parseInt($routeParams.id)
  Records.oauthApplications.findOrFetchById(parseInt($routeParams.id)).then @init, (error) ->
    $rootScope.$broadcast('pageError', error)

  return
