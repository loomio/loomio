angular.module('loomioApp').controller 'RegisteredAppsPageController', ($scope, $rootScope, Records, ModalService, RegisteredAppForm, RemoveAppForm) ->
  $rootScope.$broadcast('currentComponent', {page: 'registeredAppsPage'})
  $rootScope.$broadcast('setTitle', 'OAuth Application Dashboard')

  @loading = true
  @applications = ->
    Records.oauthApplications.collection.data
  Records.oauthApplications.fetchOwned().then => @loading = false

  @openApplicationForm = (application) ->
    ModalService.open RegisteredAppForm, application: -> Records.oauthApplications.build()

  @openDestroyForm = (application) ->
    ModalService.open RemoveAppForm, application: -> application

  return
