import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import AttachmentModel        from '@/shared/models/attachment_model';

export default class AttachmentRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = AttachmentModel;
    this.baseConstructor(recordStore);
  }
};
