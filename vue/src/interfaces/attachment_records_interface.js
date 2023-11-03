import BaseRecordsInterface from '@/record_store/base_records_interface';
import AttachmentModel        from '@/models/attachment_model';

export default class AttachmentRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = AttachmentModel;
    this.baseConstructor(recordStore);
  }
};
