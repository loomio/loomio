angular.module('loomioApp').factory 'InvitationsClient', (RestfulClient) ->
  class InvitationsClient extends RestfulClient

    constructor: ->
      @resourcePlural = 'invitations'
