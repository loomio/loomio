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

<template lang="pug">
v-card.document-card.lmo-no-print
  v-subheader(v-t="'document.list.title'")
  v-card-text
    loading(v-if='isEmpty')
    .document-card__content(v-if='!isEmpty')
      .lmo-hint-text(v-t="'document.card.no_documents'", v-if='!group.hasDocuments()')
      document-list(:model='group', :hide-preview='true', :hide-date='true')
  v-card-actions
    v-btn(flat='', :to="urlFor(group, 'documents')", v-t="'document.card.view_documents'")
</template>
