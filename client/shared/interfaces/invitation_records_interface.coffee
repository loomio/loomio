BaseRecordsInterface = require 'shared/record_store/base_records_interface.coffee'
InvitationModel      = require 'shared/models/invitation_model.coffee'

module.exports = class InvitationRecordsInterface extends BaseRecordsInterface
  model: InvitationModel

  sendByEmail: (invitationForm) =>
    @remote.post 'bulk_create', _.merge(invitationForm.serialize(), { group_id: invitationForm.groupId })

  fetchPendingByGroup: (groupKey, options = {}) ->
    options['group_key'] = groupKey
    @remote.get('/pending', options)

  fetchShareableInvitationByGroupId: (groupId, options = {}) ->
    return unless groupId
    options['group_id'] = groupId
    @remote.get('/shareable', options)
