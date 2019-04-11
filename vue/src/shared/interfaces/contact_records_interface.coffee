import BaseRecordsInterface from  '@/shared/record_store/base_records_interface'
import ContactModel    from  '@/shared/models/contact_model'

export default class ContactRecordsInterface extends BaseRecordsInterface
  model: ContactModel

  fetchInvitables: (fragment, groupKey) ->
    @fetch
      params: { q: fragment, group_key: groupKey }
