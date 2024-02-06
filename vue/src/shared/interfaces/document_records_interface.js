import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import DocumentModel        from '@/shared/models/document_model';

export default class DocumentRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = DocumentModel;
    this.baseConstructor(recordStore);
  }

  fetchByModel(model) {
    return this.fetch({
      params: {
        [`${model.constructor.singular}_id`]: model.id
      }
    });
  }

  fetchByDiscussion(discussion) {
    return this.fetch({
      path: 'for_discussion',
      params: {
        discussion_key: discussion.key
      }
    });
  }
};
