import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import WebhookModel   from '@/shared/models/webhook_model'

export default class WebhookRecordsInterface extends BaseRecordsInterface
  model: WebhookModel
