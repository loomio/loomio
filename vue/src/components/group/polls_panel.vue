<script lang="coffee">
import Records from '@/shared/services/records'
import RecordLoader from '@/shared/services/record_loader'
import WatchRecords from '@/mixins/watch_records'
import { debounce, some, every } from 'lodash'

export default
  mixins: [WatchRecords]

  data: ->
    group: Records.groups.fuzzyFind(@$route.params.key)
    polls: []
    fragment: ''
    loader: null
    per: 25
    from: 0

  created: ->
    @loader = new RecordLoader
      collection: 'polls'
      path: 'search'
      params:
        group_key: @group.key
        from: @from
        per: @per
        query: @fragment

    @fetch()

    @watchRecords
      collections: ['polls']
      query: (store) =>
        chain = store.polls.collection.chain().find(groupId: @group.id)
        if @fragment
          chain = chain.where (poll) =>
            some [poll.title, poll.details], (field) =>
              every @fragment.split(' '), (frag) -> RegExp(frag, "i").test(field)

        @polls = chain.simplesort('closing_at').limit(@loader.numRequested).data()

  methods:
    fetch: debounce ->
      @loader.fetchRecords
        from: @from
        query: @fragment
    ,
      300

  computed:
    totalRecords: -> @group.pollsCount
    showLoadMore: ->
      !@loader.loading && @loader.numRequested < @totalRecords && !@fragment.length
  watch:
    fragment: -> @fetch()


</script>

<template lang="pug">
div
  v-toolbar
    v-text-field(solo append-icon="mdi-magnify" v-model="fragment" :placeholder="$t('common.action.search')")
    v-spacer

    //- order by name, created at
    //- kind: all, or something specific
  v-progress-linear(indeterminate :active="loader.loading && !loader.loadingFirst")
  loading(:until="!loader.loadingFirst").group-polls-panel
    v-list(two-line avatar v-if='polls.length')
      poll-common-preview(:poll='poll', v-for='poll in polls', :key='poll.id')

    //- | Showing x of {{totalRecords}} total
    v-btn(v-if="showLoadMore" @click="loader.loadMore()" v-t="'common.action.load_more'")
    v-alert(v-if='polls.length == 0' :value="true" color="grey" outline icon="info" v-t="'group_polls_panel.no_polls'")
    | {{ {loading: loader.loading, numRequested: loader.numRequested, totalRecords: totalRecords,  fragment: fragment, length: polls.length} }}
</template>
