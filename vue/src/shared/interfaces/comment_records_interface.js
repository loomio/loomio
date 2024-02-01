import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import CommentModel         from '@/shared/models/comment_model';

export default class CommentRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = CommentModel;
    this.baseConstructor(recordStore);
  }
}
