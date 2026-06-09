import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import BookmarkModel        from '@/shared/models/bookmark_model';

export default class BookmarkRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = BookmarkModel;
    this.baseConstructor(recordStore);
  }
}
