import {capitalize, uniq, union, filter, map, includes } from 'lodash-es';
import Records from "@/shared/services/records";

export default new class HasDocuments {
  apply(model, opts) {
    if (opts == null) { opts = {}; }
    model.newDocumentIds     = model.newDocumentIds || [];
    model.removedDocumentIds = model.removedDocumentIds || [];

    model.documents = () => Records.documents.find({
      modelId: model.id,
      modelType: capitalize(model.constructor.singular)
    });

    model.newDocuments = () => Records.documents.find(model.newDocumentIds);

    model.newAndPersistedDocuments = () => uniq(filter(union(model.documents(), model.newDocuments()), doc => !includes(model.removedDocumentIds, doc.id))
    );

    model.hasDocuments = () => model.newAndPersistedDocuments().length > 0;

    model.serialize = function() {
      const data = this.baseSerialize();
      const root = model.constructor.serializationRoot || model.constructor.singular;
      data[root].document_ids = map(model.newAndPersistedDocuments(), 'id');
      return data;
    };

    model.showDocumentTitle = opts.showTitle;
    return model.documentsApplied = true;
  }
}
