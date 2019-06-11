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
import MembershipRequestForm from '@/components/group/membership_request_form'
import MembershipModal from '@/components/group/membership_modal'
import ChangePasswordForm from '@/components/profile/change_password_form'
import PollCommonOutcomeModal from '@/components/poll/common/outcome_modal'
import PollCommonCloseModal from '@/components/poll/common/close_modal'
import PollCommonReopenModal from '@/components/poll/common/reopen_modal'
import AnnouncementForm from '@/components/announcement/form'
import MoveThreadForm from '@/components/thread/move_thread_form'
import PollCommonAddOptionModal from '@/components/poll/common/add_option_modal'
import RevisionHistoryModal from '@/components/revision_history/modal'

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
    'MembershipRequestForm': MembershipRequestForm
    'MembershipModal': MembershipModal
    'ChangePasswordForm': ChangePasswordForm
    'PollCommonOutcomeModal': PollCommonOutcomeModal
    'PollCommonCloseModal': PollCommonCloseModal
    'PollCommonReopenModal': PollCommonReopenModal
    'AnnouncementForm': AnnouncementForm
    'MoveThreadForm': MoveThreadForm
    'PollCommonAddOptionModal': PollCommonAddOptionModal
    'RevisionHistoryModal': RevisionHistoryModal
  data: ->
    isOpen: false
    componentName: ""
    componentProps: {}

  created: ->
    EventBus.$on('openModal', @openModal)
    EventBus.$on('closeModal', @closeModal)

  methods:
    openModal: (opts) ->
      @isOpen = true
      @componentName = opts.component
      @componentProps = opts.props
    closeModal: -> @isOpen = false
    componentKey: ->
      date = new Date()
      date.getTime()


</script>

<template lang="pug">
v-dialog(v-model="isOpen" max-width="600px")
  component(:is="componentName" :key="componentKey()" v-bind="componentProps" :close="closeModal" lazy scrollable persistent)

</template>
