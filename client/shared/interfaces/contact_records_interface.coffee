BaseRecordsInterface = require 'shared/record_store/base_records_interface'
ContactModel    = require 'shared/models/contact_model'

module.exports = class ContactRecordsInterface extends BaseRecordsInterface
  model: ContactModel

  fetchInvitables: (fragment, groupKey) ->
    @fetch
      params: { q: fragment, group_key: groupKey }
