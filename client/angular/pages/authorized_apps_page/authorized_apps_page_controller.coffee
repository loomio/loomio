Records      = require 'shared/services/records.coffee'
EventBus     = require 'shared/services/event_bus.coffee'
ModalService = require 'shared/services/modal_service.coffee'

$controller = ($scope, $rootScope) ->
  EventBus.broadcast $rootScope, 'currentComponent', {title: 'Apps', page: 'authorizedAppsPage'}

  @loading = true
  @applications = ->
    Records.oauthApplications.find(authorized: true)
  Records.oauthApplications.fetchAuthorized().then => @loading = false

  @openRevokeForm = (application) ->
    ModalService.open 'RevokeAppForm', application: -> application

  return

$controller.$inject = ['$scope', '$rootScope']
angular.module('loomioApp').controller 'AuthorizedAppsPageController', $controller
