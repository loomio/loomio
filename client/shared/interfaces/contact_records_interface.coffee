BaseRecordsInterface = require 'shared/interfaces/base_records_interface.coffee'
ContactModel    = require 'shared/models/contact_model.coffee'

module.exports = class ContactRecordsInterface extends BaseRecordsInterface
  model: ContactModel

  fetchInvitables: (fragment, groupKey) ->
    @fetch
      params: { q: fragment, group_key: groupKey }
