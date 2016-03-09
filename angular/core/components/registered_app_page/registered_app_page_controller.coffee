angular.module('loomioApp').controller 'RegisteredAppPageController', ($scope, $rootScope, $routeParams, Records, FlashService, ModalService, RegisteredAppForm, RemoveAppForm) ->

  @init = (application) =>
    if application and !@application?
      @application = application
      $rootScope.$broadcast 'currentComponent', { page: 'oauthApplicationPage'}
      $rootScope.$broadcast 'setTitle', @application.name

  @init Records.oauthApplications.find parseInt($routeParams.id)
  Records.oauthApplications.findOrFetchById(parseInt($routeParams.id)).then @init, (error) ->
    $rootScope.$broadcast('pageError', error)

  @copied = ->
    FlashService.success('common.copied')

  @openRemoveForm = ->
    ModalService.open RemoveAppForm, application: => @application

  @openEditForm = ->
    ModalService.open RegisteredAppForm, application: => @application

  return
