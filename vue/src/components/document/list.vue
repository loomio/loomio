<script lang="coffee">
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import {flatten, capitalize, includes} from 'lodash'

export default
  props:
    model: Object
    showEdit: Boolean
    hidePreview: Boolean
    hideDate: Boolean
    fetch: Boolean
    placeholder: String

  data: ->
    documents: []

  created: ->
    if @couldHaveDocuments
      if @model.isA('discussion')
        Records.documents.fetchByDiscussion(@model)

      if @model.isA('poll') or @model.isA('outcome') or @model.isA('group')
        Records.documents.fetchByModel(@model)

      @watchRecords
        collections: ['documents']
        query: (store) =>
          @documents = store.documents.collection.chain().find(
            modelId: {$in: flatten([@model.id, @model.newDocumentIds])}
            modelType: capitalize(@model.constructor.singular)).
            where((doc) => !includes @model.removedDocumentIds, doc.id).
            simplesort('createdAt', true).data()

  methods:
    edit: (doc, $mdMenu) ->
      EventBus.$emit 'initializeDocument', doc, $mdMenu

    deleteDocument: (document) ->
      EventBus.$emit 'openModal',
        component: 'ConfirmModal'
        props:
          confirm:
            submit: document.destroy
            text:
              title:    'comment_form.attachments.remove_attachment'
              helptext: 'poll_common_delete_modal.question'
              submit:   'common.action.delete'
              flash:    'poll_common_delete_modal.success'

  computed:
    couldHaveDocuments: ->
      @model.createdAt < (new Date("2020-08-01T00:00:00"))

    showTitle: ->
      (@model.showDocumentTitle or @showEdit) and
      (@model.hasDocuments() or @placeholder)

    canDelete: ->
      AbilityService.canEditGroup(@model.group())
</script>

<template lang="pug">
section.document-list(v-if="couldHaveDocuments")
  p.caption(v-if='!model.hasDocuments() && placeholder', v-t='placeholder')
  .document-list__documents
    .attachment-list__item(:class="{'document-list__document--image': document.isAnImage() && !hidePreview}", v-for='document in documents', :key='document.id')
      a.attachment-list__preview(v-if='document.isAnImage() && !hidePreview' :href='document.url' target='_blank')
        img(:src='document.webUrl', :alt='document.title')
      .attachment-list__item-details
        a.document-list__title(:href='document.url' target='_blank') {{ document.title }}
        v-btn.ml-2(v-if="canDelete" icon :aria-label="$t('common.action.delete')" @click='deleteDocument(document)')
          v-icon(size="medium") mdi-delete
</template>
<style lang="sass">
.document-list
  img
    width: 100%
    height: auto

</style>
