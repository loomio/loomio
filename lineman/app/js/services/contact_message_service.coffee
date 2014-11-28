angular.module('loomioApp').factory 'ContactMessageService', ($http, RestfulService) ->
  new class ContactMessageService extends RestfulService
    resource_plural: 'contact_messages'
