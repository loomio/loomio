<script lang="coffee">
import EventBus from "@/shared/services/event_bus"
import GroupForm from '@/components/group/form.vue'
import DiscussionForm from '@/components/discussion/form.vue'
import ArrangementForm from '@/components/thread/arrangement_form.vue'
import EditCommentForm from '@/components/thread/edit_comment_form.vue'
import ConfirmModal from '@/components/common/confirm_modal.vue'
import ChangeVolumeForm from '@/components/common/change_volume_form'
import PollCommonModal from '@/components/poll/common/modal'
import PollCommonEditVoteModal from '@/components/poll/common/edit_vote_modal'
import ContactRequestForm from '@/components/contact/request_form'
import AuthModal from '@/components/auth/modal'
import MembershipRequestForm from '@/components/group/membership_request_form'
import MembershipModal from '@/components/group/membership_modal'
import ChangePasswordForm from '@/components/profile/change_password_form'
import PollCommonOutcomeModal from '@/components/poll/common/outcome_modal'
import PollCommonReopenModal from '@/components/poll/common/reopen_modal'
import PollCommonStartForm from '@/components/poll/common/start_form'
import MoveThreadForm from '@/components/thread/move_thread_form'
import PollCommonMoveForm from '@/components/poll/common/move_form'
import PollCommonAddOptionModal from '@/components/poll/common/add_option_modal'
import RevisionHistoryModal from '@/components/revision_history/modal'
import TagsSelect from '@/components/tags/select'
import TagsModal from '@/components/tags/modal'
import WebhookForm from '@/components/webhook/form'
import WebhookList from '@/components/webhook/list'
import ChangePictureForm from '@/components/profile/change_picture_form'
import GroupNewForm from '@/components/group/new_form'
import PinEventForm from '@/components/thread/pin_event_form'
import MoveCommentsModal from '@/components/discussion/move_comments_modal'
import ExportDataModal from '@/components/group/export_data_modal'
import InstallSamlProviderModal from '@/components/install_saml_provider/modal'
import GroupSurvey from '@/components/group/survey'
import AddPollToThreadModal from '@/components/poll/add_to_thread_modal'
import StrandMembersList from '@/components/strand/members_list'
import PollMembers from '@/components/poll/members'
import PollReminderForm from '@/components/poll/reminder_form'
import GroupInvitationForm from '@/components/group/invitation_form'
import AnnouncementHistory from '@/components/common/announcement_history'

export default
  components: {
    AnnouncementHistory
    GroupForm
    DiscussionForm
    EditCommentForm
    ConfirmModal
    ChangeVolumeForm
    PollCommonModal
    PollCommonEditVoteModal
    ContactRequestForm
    AuthModal
    MembershipRequestForm
    MembershipModal
    ChangePasswordForm
    PollCommonOutcomeModal
    PollCommonReopenModal
    PollCommonMoveForm
    ArrangementForm
    MoveThreadForm
    PollCommonAddOptionModal
    PollCommonStartForm
    RevisionHistoryModal
    TagsModal
    TagsSelect
    WebhookForm
    WebhookList
    ChangePictureForm
    GroupNewForm
    PinEventForm
    MoveCommentsModal
    ExportDataModal
    InstallSamlProviderModal
    GroupSurvey
    AddPollToThreadModal
    StrandMembersList
    PollMembers
    PollReminderForm
    GroupInvitationForm
  }

  data: ->
    isOpen: false
    componentName: ""
    componentProps: {}
    maxWidth: 640

  created: ->
    EventBus.$on('openModal', @openModal)
    EventBus.$on('closeModal', @doCloseModal)

  methods:
    openModal: (opts) ->
      @maxWidth = opts.maxWidth || 640
      @isOpen = true
      @componentName = opts.component
      @componentProps = opts.props
      setTimeout =>
        if @$refs.modalLauncher && document.querySelector('.modal-launcher h1')
          document.querySelector('.modal-launcher h1').focus()

    doCloseModal: -> @isOpen = false

    componentKey: ->
      date = new Date()
      date.getTime()


</script>

<template lang="pug">
v-dialog.modal-launcher(ref="modalLauncher" v-model="isOpen" :max-width="maxWidth" persistent :fullscreen="$vuetify.breakpoint.xs")
  v-card
    component(:is="componentName" :key="componentKey()" v-bind="componentProps" :close="closeModal")
</template>
