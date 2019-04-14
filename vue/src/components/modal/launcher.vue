<script lang="coffee">
import EventBus from "@/shared/services/event_bus"
import DiscussionStartModal from '@/components/discussion/start.vue'
import GroupForm from '@/components/group/form.vue'

export default
  components:
    'DiscussionStart': DiscussionStartModal
    'GroupForm': GroupForm
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
  component(:is="componentName" v-bind="componentProps" :close="closeModal" lazy scrollable persistent)

</template>
