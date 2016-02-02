angular.module('loomioApp').factory 'InvitationRecordsInterface', (BaseRecordsInterface, InvitationModel) ->
  class InvitationRecordsInterface extends BaseRecordsInterface
    model: InvitationModel

    sendByEmail: ({groupId, emailAddresses, message}) ->
      @remote.create
        group_id: groupId
        email_addresses: emailAddresses
        message: message

    fetchPendingByGroup: (groupKey, options = {}) ->
      options['group_key'] = groupKey
      @remote.get('/pending', options)

    fetchShareableInvitationByGroupId: (groupId, options = {}) ->
      options['group_id'] = groupId
      @remote.get('/shareable', options)
