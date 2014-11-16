angular.module('loomioApp').factory 'InvitationService', ($http, RestfulService) ->
  new class InvitationService extends RestfulService
    resource_plural: 'invitations'
