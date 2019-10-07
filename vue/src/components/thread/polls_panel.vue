<script lang="coffee">
import Records       from '@/shared/services/records'
import LmoUrlService from '@/shared/services/lmo_url_service'

export default
  data: ->
    discussion: null
    loading: false
    polls: []
  created: ->
    @discussion = Records.discussions.find(@$route.params.key)
    @fetchRecords()
    @watchRecords
      collections: ['polls']
      query: (store) =>
        @polls = store.polls.collection.chain()
          .find(discussionId: @discussion.id)
          .compoundsort([['latest', true], ['createdAt', true]])
          .data()
  methods:
    fetchRecords: ->
      @loading = true
      Records.polls.fetchFor(@discussion).then =>
        @loading = false

</script>

<template lang="pug">
.polls-panel
  p.text-center(v-if="!polls.length" v-t="'group_polls_panel.no_polls'")
  v-list.poll-common-index-card__polls(two-line v-if='polls.length')
    poll-common-preview(v-for='poll in polls', :key='poll.id', :poll='poll')
  loading(v-if="loading")
</template>
