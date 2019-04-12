import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import ContactRequestModel  from '@/shared/models/contact_request_model'

export default class ContactRequestRecordsInterface extends BaseRecordsInterface
  model: ContactRequestModel
