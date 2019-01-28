Records       = require 'shared/services/records'
import Vuex from 'vuex'

module.exports = new Vuex.Store
  state:
    discussions: Records.discussions.collection.data
    comments: Records.comments.collection.data
    groups: Records.groups.collection.data
    documents: Records.documents.collection.data
    notifications: Records.notifications.collection.data

  getters:
    documentsFor: (state) => (model) =>
      state.documents.collection.chain().
        find(modelId: model.id).
        find(modelType: _.capitalize(model.constructor.singular))
        .data()

    newDocumentsFor: (state) => (model) =>
      state.documents.find(model.newDocumentIds)

    newAndPersistedDocumentsFor: (state, getters) => (model) =>
      _.uniq _.filter _.union(getters.documentsFor(model), getters.newDocumentsFor(model)), (doc) ->
        !_.includes model.removedDocumentIds, doc.id

    hasDocumentsFor: (state, getters) => (model) =>
      getters.newAndPersistedDocumentsFor(model).length > 0

  mutations:
    increment: (state) ->
      state.count += 1
