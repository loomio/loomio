import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import IdentityModel        from '@/shared/models/identity_model'

export default class IdentityRecordsInterface extends BaseRecordsInterface
  model: IdentityModel

  performCommand: (id, command) ->
    @remote.getMember(id, command)
