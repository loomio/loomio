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

<script lang="coffee">
Records        = require 'shared/services/records'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'

module.exports =
  props:
    model: Object
    showEdit: Boolean
    hidePreview: Boolean
    hideDate: Boolean
    skipFetch: Boolean
    placeholder: String
    
  created: ->
    unless @model.isNew() or @skipFetch
      Records.documents.fetchByModel(@model)

  methods:
    edit: (doc, $mdMenu) ->
      EventBus.broadcast @, 'initializeDocument', doc, $mdMenu

  computed:
    documents: ->
      @$store.getters.documentsFor(@model)

    orderedDocuments: ->
      _.orderBy(@$store.getters.newAndPersistedDocumentsFor(@model), ['-createdAt'])

    showTitle: ->
      (@model.showDocumentTitle or @showEdit) and
      (@model.hasDocuments() or @placeholder)
</script>

<template>
      <section class="document-list">
        <h3
          v-if="showTitle"
          v-t="{ path: 'document.list.title' }"
          class="document-list__heading lmo-card-heading"
        ></h3>
        <p
          v-if="!model.hasDocuments() && placeholder"
          v-t="placeholder"
          class="lmo-hint-text md-caption"
        ></p>
        <div
          class="document-list__documents md-block lmo-flex lmo-flex--column"
        >
          <div
            :class="{'document-list__document--image': document.isAnImage() && !hidePreview}"
            v-for="document in orderedDocuments"
            :key="document.id"
            class="document-list__document lmo-flex lmo-flex--column"
          >
            <div
              v-if="document.isAnImage() && !hidePreview"
              class="document-list__image"
            >
              <router-link
                :to="document.url"
                target="_blank"
                class="lmo-pointer"
              >
                <img
                  :src="document.webUrl"
                  :alt="document.title"
                >
              </router-link>
            </div>
            <div
              layout="row"
              class="document-list__entry lmo-flex lmo-flex__center"
            >
              <i
                :class="`mdi lmo-margin-right mdi-${document.icon}`"
                :style="{color: document.color}"
              ></i>
              <router-link
                :to="document.url"
                target="_blank"
                class="lmo-pointer lmo-relative lmo-truncate lmo-flex lmo-flex__grow"
              >
                <div
                  class="document-list__title lmo-truncate lmo-flex__grow"
                >
                  {{ document.title }}
                </div>
              </router-link>
              <div
                v-if="!hideDate && !showEdit"
                class="document-list__upload-time md-caption lmo-flex__shrink"
              >
                {{ document.createdAt.fromNow() }}
              </div>
              <!-- <document_list_edit
                document="document"
                ng-if="showEdit"
              ></document_list_edit> -->
              <button
                v-if="showEdit"
                @click="$emit('documentRemoved', document)"
                class="md-button--tiny"
              >
                <i class="mdi mdi-close"></i>
              </button>
            </div>
          </div>
        </div>
      </section>
</template>
