<script lang="coffee">
import Records        from '@/shared/services/records'
import RecordLoader   from '@/shared/services/record_loader'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import ModalService   from '@/shared/services/modal_service'
import WatchRecords   from '@/mixins/watch_records'
import Session       from '@/shared/services/session'

import { isEmpty, intersection, debounce, filter, some, orderBy } from 'lodash'
import { applyLoadingFunction } from '@/shared/helpers/apply'

export default
  mixins: [WatchRecords]

  data: ->
    group: null
    loader: null
    attachmentLoader: null
    fragment: ''
    items: []
    subgroups: 'mine'
    per: 25
    from: 0

  created: ->
    @group = Records.groups.fuzzyFind(@$route.params.key)

    EventBus.$emit 'currentComponent',
      page: 'groupPage'
      title: @group.name
      group: @group
      search:
        placeholder: @$t('navbar.search_files', name: @group.parentOrSelf().name)

    @loader = new RecordLoader
      collection: 'documents'
      path: 'for_group'
      params:
        group_id: @group.id
        per: @per
        subgroups: @subgroups
        from: @from

    @attachmentLoader = new RecordLoader
      collection: 'attachments'
      params:
        group_id: @group.id
        per: @per
        subgroups: @subgroups
        from: @from

    @watchRecords
      collections: ['documents', 'attachments']
      query: => @query()

    @fragment = @$route.query.q || ''
    @fetch()

  watch:
    '$route.query.q': (val) ->
      @fragment = val || ''
      @fetch()
      @query()

  methods:
    query: ->
      groupIds = switch @subgroups
        when 'none' then [@group.id]
        when 'mine' then intersection(@group.organisationIds(), Session.user().groupIds())
        when 'all' then @group.organisationIds()

      documents = Records.documents.collection.chain().
                     find(groupId: {$in: groupIds}).
                     find(title: {$regex: ///#{@fragment}///i}).
                     limit(@from + @per).data()

      attachments = Records.attachments.collection.chain().
                     find(groupId: {$in: groupIds}).
                     find(filename: {$regex: ///#{@fragment}///i}).
                     limit(@from + @per).data()

      @items = orderBy(documents.concat(attachments), 'createdAt', 'desc')

    fetch: debounce ->
      @loader.fetchRecords
        q: @fragment
        from: @from

      @attachmentLoader.fetchRecords
        q: @fragment
        from: @from
    , 500

    loadMore: ->
      @from += @per
      @fetch()


  computed:
    showLoadMore: -> !@loader.exhausted && !@attachmentLoader.exhausted
    loading: -> @loader.loading || @attachmentLoader.loading
    canAdministerGroup: -> AbilityService.canAdministerGroup(@group)

</script>

<template lang="pug">
v-card.group-files-panel
  //- v-toolbar(flat transparent)
  //-   v-spacer
  //- v-divider
  //-
  //- v-alert(:value="true" color="info" outlined icon="info" v-t="'group_files_panel.no_files'")

  v-simple-table(:items="items" hide-default-footer)
    thead
      tr
        th(v-t="'group_files_panel.filename'")
        th(v-t="'group_files_panel.uploaded_by'")
        th(v-t="'group_files_panel.uploaded_at'")
    tbody
      tr(v-for="item in items" :key="item.id")
        td
          v-layout(align-center)
            v-icon mdi-{{item.icon}}
            a(:href="item.downloadUrl || item.url") {{item.filename || item.title }}
        td
          user-avatar(:user="item.author()")
        td
          time-ago(:date="item.createdAt")
  v-layout(justify-center)
    v-btn.my-2(outlined color='accent' v-if="!loader.exhausted" :loading="loading" @click="loadMore()" v-t="'common.action.load_more'")
</template>
