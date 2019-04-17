<script lang="coffee">
import EventBus from "@/shared/services/event_bus"
import GroupForm from '@/components/group/form.vue'
import DiscussionForm from '@/components/discussion/form.vue'
import EditCommentForm from '@/components/thread/edit_comment_form.vue'
import ConfirmModal from '@/components/common/confirm_modal.vue'
import ChangeVolumeForm from '@/components/common/change_volume_form'
import PollCommonStartModal from '@/components/poll/common/start_modal'
import PollCommonEditVoteModal from '@/components/poll/common/edit_vote_modal'
import PollCommonEditModal from '@/components/poll/common/edit_modal'
import ContactRequestForm from '@/components/contact/request_form'
import AuthModal from '@/components/auth/modal'

export default
  components:
    'GroupForm': GroupForm
    'DiscussionForm': DiscussionForm
    'EditCommentForm': EditCommentForm
    'ConfirmModal': ConfirmModal
    'ChangeVolumeForm': ChangeVolumeForm
    'PollCommonStartModal': PollCommonStartModal
    'PollCommonEditVoteModal': PollCommonEditVoteModal
    'PollCommonEditModal': PollCommonEditModal
    'ContactRequestForm': ContactRequestForm
    'AuthModal': AuthModal
  data: ->
    isOpen: false
    componentName: ""
    componentProps: {}

  created: ->
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
v-dialog(v-model="isOpen" max-width="600px")
  component(:is="componentName" v-bind="componentProps" :close="closeModal" lazy scrollable persistent)

</template>
