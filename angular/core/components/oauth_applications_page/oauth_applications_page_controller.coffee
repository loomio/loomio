angular.module('loomioApp').controller 'OauthApplicationsPageController', ($scope, $rootScope, Records, ModalService, OauthApplicationForm, RemoveOauthApplicationForm) ->
  $rootScope.$broadcast('currentComponent', {page: 'oauthApplicationsPage'})
  $rootScope.$broadcast('setTitle', 'OAuth Dashboard')

  @loading = true
  @applications = ->
    Records.oauthApplications.collection.data
  Records.oauthApplications.fetch(params: {}).then => @loading = false

  @openApplicationForm = (application) ->
    ModalService.open OauthApplicationForm, application: -> Records.oauthApplications.build()

  @openDestroyForm = (application) ->
    ModalService.open RemoveOauthApplicationForm, application: -> application

  return
