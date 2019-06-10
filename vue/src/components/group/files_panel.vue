<script lang="coffee">
import Records        from '@/shared/services/records'
import RecordLoader   from '@/shared/services/record_loader'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import ModalService   from '@/shared/services/modal_service'
import WatchRecords   from '@/mixins/watch_records'

import { isEmpty, throttle, filter, some } from 'lodash'
import { applyLoadingFunction } from '@/shared/helpers/apply'

export default
  mixins: [WatchRecords]

  data: ->
    group: null
    loader: null
    fragment: ''
    documents: []
    limit: 20
    offset: 0

  created: ->
    @group = Records.groups.fuzzyFind(@$route.params.key)

    @fetch()

    @watchRecords
      collections: ['documents']
      query: (store) =>
        @documents = store.documents.collection.chain().
                       find(groupId: @group.id).
                       find(title: {$regex: ///#{@fragment}///i}).
                       simplesort('title').
                       limit(@limit).offset(@offset).data()
    , (error) ->
      EventBus.$emit 'pageError', error

  watch:
    fragment: -> @fetch()

  methods:
    fetch: throttle ->
      @offset = 0
      @loader = new RecordLoader
        collection: 'documents'
        path: 'for_group'
        params:
          q: @fragment
          group_id: @group.id
          per: @limit
          from: @offset
      @loader.fetchRecords()
    ,
      200

    addDocument: ->
      ModalService.open 'DocumentModal', doc: =>
        Records.documents.build
          modelId:   @group.id
          modelType: 'Group'

  computed:
    canAdministerGroup: -> AbilityService.canAdministerGroup(@group)

</script>

<template lang="pug">
.group-files-panel
  //- at this stage, just list documents
  //- then list "attachments" and convert documents to attachments
  //- then provide ability to add files
  v-toolbar
    v-toolbar-items
      v-text-field(solo v-model="fragment" append-icon="mdi-magnify" :label="$t('common.action.search')")
    v-spacer
    v-btn.group-files-panel__addFile(outline color="primary" @click='addDocument()' v-if='canAdministerGroup' v-t="'documents_page.add_document'")

  v-data-table(:items="documents" :items-per-page="10")
    template(v-slot:no-data)
      v-alert(v-if='documents.length == 0' :value="true" color="grey" outline icon="info" v-t="'group_files_panel.no_files'")
    template(v-slot:items="props")
      td
        v-layout(align-center)
          v-icon mdi-{{props.item.icon}}
          a(:href="props.item.url") {{props.item.title}}
      td
        user-avatar(:user="props.item.author()")
        | {{props.item.author().name}}
      td {{props.item.createdAt}}
</template>
