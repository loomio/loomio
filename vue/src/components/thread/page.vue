<script lang="coffee">
import Records from '@/shared/services/records'
export default
  data: ->
    discussion: null

  created: -> @init()

  watch:
    $route: 'init'
    discussion: (currentDiscussion, prevDiscussion) ->
      @init() if prevDiscussion && currentDiscussion && (currentDiscussion.id != prevDiscussion.id)

  methods:
    init: ->
      Records.discussions.findOrFetchById(@$route.params.key).then (discussion) =>
        @discussion = discussion

</script>

<template lang="pug">
loading(:until="discussion")
  div(v-if="discussion")
    group-cover-image(:group="discussion.group()")
    v-container.thread-page
      discussion-fork-actions(:discussion='discussion', v-show='discussion.isForking()')
      thread-card(:discussion="discussion")
    //- v-layout
    //-   v-flex(md8)
      //- v-flex(md4)
      //-   v-layout(column)
      //-     v-flex(v-for="poll in activePolls", :key="poll.id")
      //-       poll-common-card(:poll="poll")
      //-     v-flex
      //-       decision-tools-card(:discussion='discussion')
      //-     v-flex
      //-       membership-card(:group='discussion.guestGroup()')
      //-     v-flex
      //-       membership-card(:group='discussion.guestGroup()', :pending='true')
      //-     v-flex
      //-       poll-common-index-card(:model='discussion')
</template>
