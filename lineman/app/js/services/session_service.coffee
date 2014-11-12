angular.module('loomioApp').factory 'SessionService', ($http, RestfulService) ->
  new class SessionService extends RestfulService
    resource_plural: 'sessions'