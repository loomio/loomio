<script lang="coffee">
import Records        from '@/shared/services/records'
import RecordLoader   from '@/shared/services/record_loader'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import ModalService   from '@/shared/services/modal_service'
import WatchRecords   from '@/mixins/watch_records'

import { isEmpty, debounce, filter, some, orderBy } from 'lodash'
import { applyLoadingFunction } from '@/shared/helpers/apply'

export default
  mixins: [WatchRecords]

  data: ->
    group: null
    loader: null
    attachmentLoader: null
    fragment: ''
    items: []
    per: 25
    from: 0

  created: ->
    @group = Records.groups.fuzzyFind(@$route.params.key)

    @loader = new RecordLoader
      collection: 'documents'
      path: 'for_group'
      params:
        group_id: @group.id
        per: @per
        from: @from

    @attachmentLoader = new RecordLoader
      collection: 'attachments'
      params:
        group_id: @group.id
        per: @per
        from: @from

    @fetch()

    @watchRecords
      collections: ['documents', 'attachments']
      query: @query

  watch:
    fragment: debounce ->
      @fetch()
      @query()
    ,
      300

  methods:
    query: ->
      documents = Records.documents.collection.chain().
                     find(groupId: @group.id).
                     find(title: {$regex: ///#{@fragment}///i}).
                     limit(@loader.numRequested).data()

      attachments = Records.attachments.collection.chain().
                     find(groupId: @group.id).
                     find(filename: {$regex: ///#{@fragment}///i}).
                     limit(@loader.numRequested).data()

      @items = orderBy(documents.concat(attachments), 'createdAt', 'desc')

    fetch: ->
      @loader.fetchRecords
        q: @fragment
        from: @from

      @attachmentLoader.fetchRecords
        q: @fragment
        from: @from

    loadMore: ->
      @from += @per
      @fetch()


  computed:
    showLoadMore: -> true || !@loader.exhausted && !@attachmentLoader.exhausted
    loading: -> @loader.loading || @attachmentLoader.loading
    canAdministerGroup: -> AbilityService.canAdministerGroup(@group)

</script>

<template lang="pug">
.group-files-panel
  v-toolbar(flat)
    v-toolbar-items
      v-text-field(solo flat v-model="fragment" append-icon="mdi-magnify" :label="$t('common.action.search')")
    v-spacer

  v-data-table(:items="items" :loading="loading" disable-initial-sort hide-actions)
    template(v-slot:no-data)
      v-alert(:value="true" color="info" outline icon="info" v-t="'group_files_panel.no_files'")
    template(v-slot:items="props")
      td
        v-layout(align-center)
          v-icon mdi-{{props.item.icon}}
          a(:href="props.item.downloadUrl || props.item.url") {{props.item.filename || props.item.title }}
      td
        user-avatar(:user="props.item.author()")
      td
        time-ago(:date="props.item.createdAt")
  v-btn(v-if="showLoadMore" :disabled="loading" @click="loadMore()" v-t="'common.action.load_more'")
</template>
