angular.module('loomioApp').controller 'AuthorizedAppsPageController', ($scope, $rootScope, Records, ModalService, RevokeAppForm) ->
  $rootScope.$broadcast('currentComponent', {page: 'authorizedAppsPage'})
  $rootScope.$broadcast('setTitle', 'Apps')

  @loading = true
  @applications = ->
    Records.oauthApplications.find(authorized: true)
  Records.oauthApplications.fetchAuthorized().then => @loading = false

  @openRevokeForm = (application) ->
    ModalService.open RevokeAppForm, application: -> application

  return
