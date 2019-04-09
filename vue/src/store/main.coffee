import Records        from '@/shared/services/records'
import AbilityService from '@/shared/services/ability_service'
import Session        from '@/shared/services/session'
import Vue            from 'vue'
import Vuex           from 'vuex'

Vue.use(Vuex)

export default new Vuex.Store
  state:
    discussions: Records.discussions.collection.data
    comments: Records.comments.collection.data
    groups: Records.groups.collection.data
    documents: Records.documents.collection.data
    notifications: Records.notifications.collection.data
    memberships: Records.memberships

  getters:
    documentsFor: (state) => (model) =>
      Records.documents.collection.chain().
        find(modelId: model.id).
        find(modelType: _.capitalize(model.constructor.singular))
        .data()

    newDocumentsFor: (state) => (model) =>
      Records.documents.find(model.newDocumentIds)

    newAndPersistedDocumentsFor: (state, getters) => (model) =>
      _.uniq _.filter _.union(getters.documentsFor(model), getters.newDocumentsFor(model)), (doc) ->
        !_.includes model.removedDocumentIds, doc.id

    hasDocumentsFor: (state, getters) => (model) =>
      getters.newAndPersistedDocumentsFor(model).length > 0

    canContactUser: (state, getters) => (user) =>
      return false if _.isEmpty(user) or _.isNil(user)
      AbilityService.isLoggedIn() &&
      Session.user().id != user.id &&
      _.intersection(
        _.map(state.memberships.find(userId: Session.user().id), 'groupId'),
        _.map(state.memberships.find(userId: user.id), 'groupId')
      ).length

  mutations:
    increment: (state) ->
      state.count += 1
