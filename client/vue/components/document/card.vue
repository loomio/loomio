<script lang="coffee">
Records      = require 'shared/services/records'
ModalService = require 'shared/services/modal_service'
urlFor       = require 'vue/mixins/url_for'
_isEmpty     = require 'lodash/isempty'


module.exports =
  mixins: [urlFor]
  props:
    group: Object
  created: ->
    Records.documents.fetchByGroup(@group)
  computed:
    isEmpty: -> _isEmpty(@group)
</script>

<template>
  <v-card class="document-card mb-2 lmo-no-print">
    <v-card-text>
      <h2 v-t="'document.list.title'" class="lmo-card-heading" id="document-card-title"></h2>
      <loading v-if="isEmpty"></loading>
      <div v-if="!isEmpty" class="document-card__content">
        <div v-t="'document.card.no_documents'" v-if="!group.hasDocuments()" class="lmo-hint-text"></div>
        <document-list :model="group" :hide-preview="true" :hide-date="true"></document-list>
      </div>
    </v-card-text>
    <v-card-actions>
      <v-btn flat :to="urlFor(group, 'documents')" v-t="'document.card.view_documents'"></v-btn>
    </v-card-actions>
  </v-card>
</template>

<style lang="scss">
</style>
