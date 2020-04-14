<script lang="coffee">
import Records        from '@/shared/services/records'
import RecordLoader   from '@/shared/services/record_loader'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import ModalService   from '@/shared/services/modal_service'
import Session       from '@/shared/services/session'

import { isEmpty, intersection, debounce, filter, some, orderBy } from 'lodash'

export default
  data: ->
    group: null
    loader: null
    attachmentLoader: null
    searchQuery: ''
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

    @searchQuery = @$route.query.q || ''
    @fetch()

  watch:
    '$route.query.q': debounce (val) ->
      @searchQuery = val || ''
      @fetch()
      @query()
    , 500

  methods:
    query: ->
      groupIds = switch @subgroups
        when 'none' then [@group.id]
        when 'mine' then intersection(@group.organisationIds(), Session.user().groupIds())
        when 'all' then @group.organisationIds()

      documents = Records.documents.collection.chain().
                     find(groupId: {$in: groupIds}).
                     find(title: {$regex: ///#{@searchQuery}///i}).
                     limit(@from + @per).data()

      attachments = Records.attachments.collection.chain().
                     find(groupId: {$in: groupIds}).
                     find(filename: {$regex: ///#{@searchQuery}///i}).
                     limit(@from + @per).data()

      @items = orderBy(documents.concat(attachments), 'createdAt', 'desc')

    fetch: debounce ->
      @loader.fetchRecords
        q: @searchQuery
        from: @from

      @attachmentLoader.fetchRecords
        q: @searchQuery
        from: @from
    , 500

    loadMore: ->
      @from += @per
      @fetch()

    handleSearchQueryChange: (val) ->
      @$router.replace({ query: { q: val } })

  computed:
    showLoadMore: -> !@loader.exhausted && !@attachmentLoader.exhausted
    loading: -> @loader.loading || @attachmentLoader.loading
    canAdminister: -> AbilityService.canAdminister(@group)

</script>

<template lang="pug">
div
  v-layout.py-2(align-center wrap)
    v-text-field(clearable hide-details solo @change="handleSearchQueryChange" :placeholder="$t('navbar.search_files', {name: group.name})" append-icon="mdi-magnify")
  v-card.group-files-panel(outlined)
    div(v-if="loader.status == 403")
      p.pa-4.text-center(v-t="'error_page.forbidden'")
    div(v-else)
      p.text-center.pa-4(v-if="!loading && !items.length" v-t="'common.no_results_found'")
      v-simple-table(v-else :items="items" hide-default-footer)
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
