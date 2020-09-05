<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Records from '@/shared/services/records'
import { debounce, truncate, first, last, some, drop, min, compact } from 'lodash'

export default
  props:
    discussion: Object
    loader: Object

  data: ->
    presets: []
    headings: []

  mounted: ->
    # EventBus.$on 'currentComponent', (options) =>
      # @discussion = options.discussion
      # return unless @discussion

    parser = new DOMParser()
    doc = parser.parseFromString(@discussion.description, 'text/html')
    @headings = Array.from(doc.querySelectorAll('h1,h2,h3')).map (el) =>
      {id: el.id, name: el.textContent}

    @watchRecords
      key: 'strand-nav'+@discussion.id
      collections: ["events", "discussions"]
      query: =>
        return unless @discussion && @discussion.createdEvent()
        @presets = Records.events.collection.chain()
          .find({pinned: true, discussionId: @discussion.id})
          .simplesort('position').data()

    # move this to activity panel.
    Records.events.fetch
      params:
        exclude_types: 'group discussion'
        discussion_id: @discussion.id
        pinned: true
        per: 200

</script>

<template lang="pug">
.strand-nav
  p(v-for="rule in loader.rules") {{rule}}
  ul.strand-nav
    h5 thread positions
    li(@click="loader.jumpToEarliest()") Earliest
    li(@click="loader.jumpToUnread()") Unread
    li(@click="loader.jumpToLatest()") Latest
    h5 context headings
    li(v-for="heading in headings" :key="heading.id") {{heading.name}}
    h5 pinned events
    li(v-for="event in presets" :key="event.id" @click="loader.jumpToSequenceId(event.sequenceId)") {{event.pinnedTitle || event.suggestedTitle()}}
    //- hr
    //- input(type="text" placeholder="search")
    //- li(v-for="pin in pins")
</template>

<style lang="sass">
</style>
