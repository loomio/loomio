<style>
</style>

<script lang="coffee">
Records      = require 'shared/services/records'
ModalService = require 'shared/services/modal_service'
urlFor       = require 'vue/mixins/url_for'


module.exports =
  mixins: [urlFor]
  props:
    group: Object
  created: ->
    Records.documents.fetchByGroup(@group)
</script>

<template>
    <section class="document-card lmo-card lmo-no-print">
      <h2 v-t="'document.list.title'" class="lmo-card-heading" id="document-card-title"></h2>
      <loading v-if="_.isEmpty(group)"></loading>
      <div v-if="!_.isEmpty(group)" class="document-card__content">
        <div v-t="'document.card.no_documents'" v-if="!group.hasDocuments()" class="lmo-hint-text"></div>
        <document-list :model="group" :hide-preview="true" :hide-date="true"></document-list>
      </div>
      <div class="lmo-md-actions">
        <a :href="urlFor(group, 'documents')" class="lmo-card-minor-action">
          <span v-t="'document.card.view_documents'"></span>
        </a>
      </div>
    </section>
</template>
