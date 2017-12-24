Records      = require 'shared/services/records.coffee'
ModalService = require 'shared/services/modal_service.coffee'

angular.module('loomioApp').controller 'AuthorizedAppsPageController', ($scope, $rootScope) ->
  $rootScope.$broadcast('currentComponent', {page: 'authorizedAppsPage'})
  $rootScope.$broadcast('setTitle', 'Apps')

  @loading = true
  @applications = ->
    Records.oauthApplications.find(authorized: true)
  Records.oauthApplications.fetchAuthorized().then => @loading = false

  @openRevokeForm = (application) ->
    ModalService.open 'RevokeAppForm', application: -> application

  return
