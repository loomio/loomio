<script lang="coffee">
import EventBus from "@/shared/services/event_bus"
import DiscussionStartModal from '@/components/discussion/start.vue'
import GroupStartModal from '@/components/group/start.vue'

export default
  components:
    'DiscussionStart': DiscussionStartModal
    'GroupStart': GroupStartModal
  data: ->
    isOpen: false
    componentName: ""
    componentProps: {}

  mounted: ->
    EventBus.$on('openModal', @openModal)
    EventBus.$on('closeModal', @closeModal)

  methods:
    openModal: (opts) ->
      @isOpen = true
      @componentName = opts.component
      @componentProps = opts.props
    closeModal: -> @isOpen = false

</script>

<template lang="pug">
v-dialog(v-model="isOpen")
  modal-template(title="placeholder title")
    template(v-slot:content)
      component(:is="componentName" v-bind="componentProps" :close="closeModal" lazy scrollable persistent)
    template(v-slot:actions)
      span action 1
      span action 2
      span action 3

</template>
