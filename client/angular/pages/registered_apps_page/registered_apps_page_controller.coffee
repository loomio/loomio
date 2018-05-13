Records      = require 'shared/services/records'
EventBus     = require 'shared/services/event_bus'
ModalService = require 'shared/services/modal_service'

$controller = ($scope, $rootScope) ->
  EventBus.broadcast $rootScope, 'currentComponent', {title: 'OAuth Application Dashboard', page: 'registeredAppsPage'}

  @loading = true
  @applications = ->
    Records.oauthApplications.collection.data
  Records.oauthApplications.fetchOwned().then => @loading = false

  @openApplicationForm = (application) ->
    ModalService.open 'RegisteredAppForm', application: -> Records.oauthApplications.build()

  @openDestroyForm = (application) ->
    ModalService.open 'RemoveAppForm', application: -> application

  return

$controller.$inject = ['$scope', '$rootScope']
angular.module('loomioApp').controller 'RegisteredAppsPageController', $controller
