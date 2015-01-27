angular.module('loomioApp').factory 'InvitablesClient', (RestfulClient) ->
  class InvitablesClient extends RestfulClient

    constructor: ->
      @resourcePlural = 'invitables'

    getByNameFragment: (fragment, groupId) ->
      @getCollection {q: fragment, group_id: groupId}
