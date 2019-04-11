import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import SessionModel         from '@/shared/models/session_model'

export default class SessionRecordsInterface extends BaseRecordsInterface
  model: SessionModel
