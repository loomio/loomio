angular.module('loomioApp').controller 'OauthApplicationPageController', ($scope, $rootScope, $routeParams, Records, FlashService, ModalService, OauthApplicationForm, RemoveOauthApplicationForm) ->

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
    ModalService.open RemoveOauthApplicationForm, application: => @application

  @openEditForm = ->
    ModalService.open OauthApplicationForm, application: => @application

  return
