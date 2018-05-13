Records      = require 'shared/services/records'
EventBus     = require 'shared/services/event_bus'
FlashService = require 'shared/services/flash_service'
ModalService = require 'shared/services/modal_service'

$controller = ($rootScope, $routeParams) ->

  @init = (application) =>
    if application and !@application?
      @application = application
      EventBus.broadcast $rootScope, 'currentComponent', { title: application.name, page: 'oauthApplicationPage'}

  @init Records.oauthApplications.find parseInt($routeParams.id)
  Records.oauthApplications.findOrFetchById(parseInt($routeParams.id)).then @init, (error) ->
    EventBus.broadcast $rootScope, 'pageError', error

  @copied = ->
    FlashService.success('common.copied')

  @openRemoveForm = ->
    ModalService.open 'RemoveAppForm', application: => @application

  @openEditForm = ->
    ModalService.open 'RegisteredAppForm', application: => @application

  return

$controller.$inject = ['$rootScope', '$routeParams']
angular.module('loomioApp').controller 'RegisteredAppPageController', $controller
