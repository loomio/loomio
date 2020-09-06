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
    # Records.events.fetch
    #   params:
    #     exclude_types: 'group discussion'
    #     discussion_id: @discussion.id
    #     pinned: true
    #     per: 200

</script>

<template lang="pug">
div
  div
    p readRanges {{discussion.readRanges}}
    p unreadRanges{{discussion.unreadRanges()}}
    p(v-for="rule,index in loader.rules" :key="index") {{rule}}

  .strand-nav.pt-8.d-flex.justify-center

    v-menu(scale)
      template(v-slot:activator="{ on, attrs }")
        v-btn(rounded v-bind="attrs" v-on="on")
          span.mr-2(v-t="loader.titleKey")
          v-icon(small) mdi-menu

      v-list(dense)
        //- v-list-item
        //- ul.strand-nav
        v-subheader Show me
        v-list-item(@click="loader.jumpToEarliest()") Earliest
        v-list-item(@click="loader.jumpToUnread()") Unread
        v-list-item(@click="loader.jumpToLatest()") Latest
        v-list-item(@click="loader.loadEverything()") Everything
        //- v-list-item(@click="loader.loadEverything()") Pinned
        v-subheader(v-if="headings.length") Table of contents
        v-list-item(v-for="heading, index in headings" :key="index") {{heading.name}}
        div(v-if="presets.length")
          v-subheader Pinned events
          v-list-item(v-for="event in presets" :key="event.id" @click="loader.jumpToSequenceId(event.sequenceId)") {{event.pinnedTitle || event.suggestedTitle()}}
      //- hr
      //- input(type="text" placeholder="search")
      //- li(v-for="pin in pins")
</template>

<style lang="sass">
</style>
