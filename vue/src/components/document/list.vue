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
    skipFetch: Boolean
    placeholder: String

  data: ->
    documents: []

  created: ->
    unless @model.isNew() or @skipFetch
      Records.documents.fetchByModel(@model)
    Records.view
      name: "newAndPersistedDocumentsFor(#{@model.constructor.singular}.#{@model.id})"
      collections: ['documents']
      query: (store) =>
        console.log store
        store.documents.collection.chain().find(
          modelId: {$in: flatten([@model.id, @model.newDocumentIds])}
          modelType: capitalize(@model.constructor.singular)).
          where((doc) -> !includes @model.removedDocumentIds, doc.id).
          simplesort('createdAt', true).data()

  methods:
    edit: (doc, $mdMenu) ->
      EventBus.$emit 'initializeDocument', doc, $mdMenu

  computed:
    showTitle: ->
      (@model.showDocumentTitle or @showEdit) and
      (@model.hasDocuments() or @placeholder)
</script>

<template lang="pug">
section.document-list
  h3.document-list__heading.lmo-card-heading(v-if='showTitle', v-t="{ path: 'document.list.title' }")
  p.lmo-hint-text.md-caption(v-if='!model.hasDocuments() && placeholder', v-t='placeholder')
  .document-list__documents.md-block.lmo-flex.lmo-flex--column
    .document-list__document.lmo-flex.lmo-flex--column(:class="{'document-list__document--image': document.isAnImage() && !hidePreview}", v-for='document in documents', :key='document.id')
      .document-list__image(v-if='document.isAnImage() && !hidePreview')
        router-link.lmo-pointer(:to='document.url', target='_blank')
          img(:src='document.webUrl', :alt='document.title')
      .document-list__entry.lmo-flex.lmo-flex__center(layout='row')
        i(:class='`mdi lmo-margin-right mdi-${document.icon}`', :style='{color: document.color}')
        router-link.lmo-pointer.lmo-relative.lmo-truncate.lmo-flex.lmo-flex__grow(:to='document.url', target='_blank')
          .document-list__title.lmo-truncate.lmo-flex__grow
            | {{ document.title }}
        .document-list__upload-time.md-caption.lmo-flex__shrink(v-if='!hideDate && !showEdit')
          | {{ document.createdAt.fromNow() }}
        //
          <document_list_edit
          document="document"
          ng-if="showEdit"
          ></document_list_edit>
        button.md-button--tiny(v-if='showEdit', @click="$emit('documentRemoved', document)")
          i.mdi.mdi-close
</template>

<style lang="scss">
@import 'mixins';

.document-list {
  .md-button--tiny { opacity: 0.5; }
  &:hover {
    .md-button--tiny { opacity: 1; }
  }
}

.document-list__document {
  margin: 8px 0;
  line-height: 32px;
  background: $modal-background-color;
  @include roundedCorners;
  &--image { padding-top: 8px; }
}

.document-list__entry {
  padding-left: 8px;
}

.document-list__image {
  margin: auto;
  max-width: 100%;
  img {
    max-width: 100%;
    max-height: 240px;
  }
}

.document-list .md-button--tiny {
  opacity: 0.5;
  transition: opacity ease-in-out 0.25s;
  &:hover { opacity: 1; }
}

.document-list__heading {
  font-size: 14px;
  margin-bottom: 0;
}

.document-list .mdi {
  font-size: 24px;
}

.document-list .mdi.mdi-pencil {
  font-size: 20px;
}

.document-list__title {
  color: $primary-text-color;
  font-size: 14px;
}

.document-list__upload-time {
  margin-right: 8px;
  white-space: nowrap;
}

.document-list__tooltip {
  padding-top: 8px;
  max-height: 600px;
  max-width: 400px;
}
</style>
