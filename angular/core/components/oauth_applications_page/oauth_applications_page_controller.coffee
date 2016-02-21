angular.module('loomioApp').controller 'OauthApplicationsPageController', ($scope, $rootScope, Records, ModalService, OauthApplicationForm, RemoveOauthApplicationForm) ->
  $rootScope.$broadcast('currentComponent', {page: 'oauthApplicationsPage'})
  $rootScope.$broadcast('setTitle', 'OAuth Dashboard')

  @applications = ->
    Records.oauthApplications.collection.data
  Records.oauthApplications.fetch(params: {})

  @openApplicationForm = (application) ->
    ModalService.open OauthApplicationForm, application: -> application or Records.oauthApplications.build()

  @openDestroyForm = (application) ->
    ModalService.open RemoveOauthApplicationForm, application: -> application

  return
