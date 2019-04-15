<script lang="coffee">
import EventBus from "@/shared/services/event_bus"
import GroupForm from '@/components/group/form.vue'
import DiscussionForm from '@/components/discussion/form.vue'
import EditCommentForm from '@/components/thread/edit_comment_form.vue'
import ConfirmModal from '@/components/common/confirm_modal.vue'
import ChangeVolumeForm from '@/components/common/change_volume_form'
import PollCommonStartModal from '@/components/poll/common/start_modal'

export default
  components:
    'GroupForm': GroupForm
    'DiscussionForm': DiscussionForm
    'EditCommentForm': EditCommentForm
    'ConfirmModal': ConfirmModal
    'ChangeVolumeForm': ChangeVolumeForm
    'PollCommonStartModal': PollCommonStartModal
  data: ->
    isOpen: false
    componentName: ""
    componentProps: {}

  mounted: ->
    EventBus.$on('openModal', @openModal)
    EventBus.$on('closeModal', @closeModal)

  methods:
    openModal: (opts) ->
      console.log 'openModal', opts
      @isOpen = true
      @componentName = opts.component
      @componentProps = opts.props
    closeModal: -> @isOpen = false

</script>

<template lang="pug">
v-dialog(v-model="isOpen")
  component(:is="componentName" v-bind="componentProps" :close="closeModal" lazy scrollable persistent)

</template>
