Records      = require 'shared/services/records'
EventBus     = require 'shared/services/event_bus'
ModalService = require 'shared/services/modal_service'

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
