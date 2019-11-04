<script lang="coffee">
import Records           from '@/shared/services/records'
import EventBus          from '@/shared/services/event_bus'
import AbilityService    from '@/shared/services/ability_service'

export default
  data: ->
    discussion: null

  created: -> @init()

  watch:
    '$route.params.key': 'init'
    '$route.params.comment_id': 'init'

  methods:
    init: ->
      Records.discussions.findOrFetchById(@$route.params.key).then (discussion) =>
          @discussion = discussion
          EventBus.$emit 'currentComponent',
            page: 'threadPage'
            discussion: @discussion
            group: @discussion.group()

            title: @discussion.title
      ,
        (error) -> EventBus.$emit 'pageError', error


</script>

<template lang="pug">
.thread-page
  v-content
    loading(:until="discussion")
      v-container.thread-page.max-width-800(v-if="discussion")
        thread-current-poll-banner(:discussion="discussion")
        discussion-fork-actions(:discussion='discussion' v-show='discussion.isForking' :key="'fork-actions'+ discussion.id")
        thread-card(:discussion='discussion' :key="discussion.id")
  router-view(name="nav")
</template>
