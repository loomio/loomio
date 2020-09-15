<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Records from '@/shared/services/records'
import {map} from 'lodash'

export default
  props:
    discussion: Object

  data: ->
    readers: []

  mounted: ->
    Records.discussionReaders.fetch
      path: ''
      params:
        discussion_id: @discussion.id

    @watchRecords
      collections: ['discussionReaders']
      query: (records) =>
        @readers = Records.discussionReaders.collection.chain().
          find(discussionId: @discussion.id).simplesort('lastReadAt', true).limit(20).data()

  methods:
    openInviteModal: ->
      EventBus.$emit 'openModal',
        component: 'StrandMembersList',
        props: { discussion: @discussion }

</script>

<template lang="pug">
.strand-members.d-flex
  //- mid-dot
  //- span(v-show='discussion.seenByCount > 0')
  //-   a.context-panel__seen_by_count(v-t="{ path: 'thread_context.seen_by_count', args: { count: discussion.seenByCount } }"  @click="openSeenByModal()")

  user-avatar(v-for="reader in readers" :user="reader.user()" :size="28" :key="reader.id")
  v-btn(small icon @click="openInviteModal")
    v-icon mdi-plus
</template>

<style lang="sass">
</style>
