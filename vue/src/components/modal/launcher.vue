<script lang="coffee">
import EventBus from "@/shared/services/event_bus"

export default
  data: ->
    isOpen: false

  mounted: ->
    EventBus.$on('openModal', @openModal)
    EventBus.$on('closeModal', @closeModal)

  methods:
    openModal: ->
      console.log "hi"
      @isOpen = true
    closeModal: -> @isOpen = false

  # newGroup: ->
  #   Records.groups.build()
  #
  # newThread: ->
  #   Records.discussions.build(groupId: @currentGroup().id)

  # startThread: ->
  #   ModalService.open 'DiscussionStartModal', discussion: => Records.discussions.build(groupId: @currentGroup().id)

</script>

<template lang="pug">
v-dialog(model="isOpen")
  h1 I'm open matey
  //- v-dialog(v-model='isThreadModalOpen' lazy persistent scrollable)
  //-   discussion-start(:discussion='newThread()', :close='closeThreadModal')
  //- v-dialog(v-model='isGroupModalOpen' lazy scrollable)
  //-   group-start(:group='newGroup()', :close='closeGroupModal')


</template>
