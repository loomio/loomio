BaseRecordsInterface = require '@/shared/record_store/base_records_interface'
ContactRequestModel  = require '@/shared/models/contact_request_model'

export default class ContactRequestRecordsInterface extends BaseRecordsInterface
  model: ContactRequestModel
