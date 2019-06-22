<script lang="coffee">
import Records      from '@/shared/services/records'
import ModalService from '@/shared/services/modal_service'
import UrlFor       from '@/mixins/url_for'
import { isEmpty }  from 'lodash'

export default
  mixins: [UrlFor]
  props:
    group: Object
  created: ->
    Records.documents.fetchByGroup(@group)
  computed:
    isEmpty: -> isEmpty(@group)
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
    v-btn(text :to="urlFor(group, 'documents')", v-t="'document.card.view_documents'")
</template>
