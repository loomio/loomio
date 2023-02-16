<script lang="coffee">
import PageLoader         from '@/shared/services/page_loader'
import Records from '@/shared/services/records'
import EventBus     from '@/shared/services/event_bus'
import { parseISO } from 'date-fns'

export default
  props:
    poll: Object

  data: ->
    stances: []
    per: 25
    loader: null

  created: ->
    @loader = new PageLoader
      path: 'stances'
      order: 'orderAt'
      params:
        per: @per
        poll_id: @poll.id

    @loader.fetch(@page).then => @findRecords()

    @watchRecords
      collections: ['stances', 'polls']
      query: => @findRecords()

  computed:
    page:
      get: -> parseInt(@$route.query.page) || 1
      set: (val) ->
        @$router.replace({query: Object.assign({}, @$route.query, {page: val})}) 

    totalPages: ->
      Math.ceil(parseFloat(@loader.total) / parseFloat(@per))

  watch:
    page: ->
      @loader.fetch(@page).then(=> @findRecords()).then => @scrollTo('#votes')
      @findRecords()

  methods:
    findRecords: ->
      if @loader.pageWindow[@page]
        chain = Records.stances.collection.chain().find(id: {$in: @loader.pageIds[@page]})
        chain = chain.simplesort('orderAt', true)
        @stances = chain.data()
      else
        @stances = []

</script>

<template lang="pug">
.poll-common-votes-panel
  //- v-layout.poll-common-votes-panel__header
    //- v-select(style="max-width: 200px" dense solo v-model='order' :items="sortOptions" @change='refresh()' aria-label="$t('poll_common_votes_panel.change_results_order')")
  h2.text-h5.my-2#votes(v-t="'poll_common.votes'")
  .poll-common-votes-panel__no-votes.text--secondary(v-if='!poll.votersCount' v-t="'poll_common_votes_panel.no_votes_yet'")
  .poll-common-votes-panel__has-votes(v-if='poll.votersCount')
    .poll-common-votes-panel__stance(v-for='stance in stances', :key='stance.id')
      .poll-common-votes-panel__avatar.pr-3
        user-avatar(:user='stance.participant()', :size='24')
      .poll-common-votes-panel__stance-content
        .poll-common-votes-panel__stance-name-and-option
          v-layout.text-body-2(align-center)
            .pr-2.text--secondary {{ stance.participantName() }}
            poll-common-stance-choice(
              v-if="poll.showResults() && stance.castAt && poll.singleChoice()", 
              :poll="poll", 
              :stance-choice="stance.stanceChoice()")
            span.caption(v-if='!stance.castAt' v-t="'poll_common_votes_panel.undecided'" )
            time-ago.text--secondary(v-if="stance.castAt", :date="stance.castAt")
        .poll-common-stance(v-if="poll.showResults() && stance.castAt")
          poll-common-stance-choices(:stance='stance')
          formatted-text.poll-common-stance-created__reason(:model="stance" column="reason")
    loading(v-if="loader.loading")
    v-pagination(v-model="page", :length="totalPages", :disabled="totalPages == 1")
</template>

<style lang="sass">
.poll-common-votes-panel__stance
	display: flex
	align-items: flex-start
	margin: 7px 0

</style>
