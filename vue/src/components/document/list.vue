<script lang="coffee">
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import {flatten, capitalize, includes} from 'lodash-es'
import WatchRecords from '@/mixins/watch_records'

export default
  mixins: [WatchRecords]
  props:
    model: Object
    showEdit: Boolean
    hidePreview: Boolean
    hideDate: Boolean
    skipFetch: Boolean
    placeholder: String

  data: ->
    documents: []

  created: ->
    unless @model.isNew() or @skipFetch
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
              title:    'attachments.confirm.title'
              raw_helptext: @$t("attachments.confirm.helptext", { name: document.title })
              submit:   'attachments.confirm.submit'
              flash:    'attachments.confirm.flash'

  computed:
    showTitle: ->
      (@model.showDocumentTitle or @showEdit) and
      (@model.hasDocuments() or @placeholder)

    canDelete: ->
      AbilityService.canEditGroup(@model.group())
</script>

<template lang="pug">
section.document-list
  p.caption(v-if='!model.hasDocuments() && placeholder', v-t='placeholder')
  .document-list__documents
    .attachment-list__item(:class="{'document-list__document--image': document.isAnImage() && !hidePreview}", v-for='document in documents', :key='document.id')
      v-layout.attachment-list__preview(column align-center v-if='document.isAnImage() && !hidePreview')
        a.lmo-pointer(:href='document.url' target='_blank')
          img(:src='document.webUrl', :alt='document.title')
        v-btn.ml-2(v-if="canDelete" icon :aria-label="$t('common.action.delete')" @click='deleteDocument(document)')
          v-icon(size="medium") mdi-delete
      v-layout.attachment-list__item-details
        v-icon {{ `mdi-${document.icon}` }}
        a.document-list__title(:href='document.url' target='_blank') {{ document.title }}
        v-btn.ml-2(v-if="canDelete" icon :aria-label="$t('common.action.delete')" @click='deleteDocument(document)')
          v-icon(size="medium") mdi-delete
</template>

<style lang="sass">
.attachment-list__item
  display: flex
  flex-direction: column
  margin: 8px 0
  line-height: 32px
  background: #f6f6f6
  border-radius: 2px

.attachment-list__item-details
  display: flex
  flex-direction: row
  align-items: center

.attachment-list__preview
  max-height: 320px
  max-width: 100%

</style>
