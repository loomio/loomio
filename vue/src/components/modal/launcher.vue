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
import AnnouncementForm from '@/components/announcement/form'
import AnnouncementHistory from '@/components/announcement/history'
import MoveThreadForm from '@/components/thread/move_thread_form'
import PollCommonAddOptionModal from '@/components/poll/common/add_option_modal'
import RevisionHistoryModal from '@/components/revision_history/modal'
import TagsModal from '@/components/tags/modal'
import InstallSlackModal from '@/components/install_slack/modal'
import InstallMicrosoftTeamsModal from '@/components/install_microsoft_teams/modal'
import ChangePictureForm from '@/components/profile/change_picture_form'
import GroupNewForm from '@/components/group/new_form'
import PinEventForm from '@/components/thread/pin_event_form'
import MoveCommentsModal from '@/components/discussion/move_comments_modal'
import SeenByModal from '@/components/thread/seen_by_modal'
import ExportDataModal from '@/components/group/export_data_modal'
import VueUpgradedModal from '@/components/user/vue_upgraded_modal'
import InstallSamlProviderModal from '@/components/install_saml_provider/modal'
import GroupSurvey from '@/components/group/survey'

export default
  components:
    'GroupForm': GroupForm
    'DiscussionForm': DiscussionForm
    'EditCommentForm': EditCommentForm
    'ConfirmModal': ConfirmModal
    'ChangeVolumeForm': ChangeVolumeForm
    'PollCommonModal': PollCommonModal
    'PollCommonEditVoteModal': PollCommonEditVoteModal
    'ContactRequestForm': ContactRequestForm
    'AuthModal': AuthModal
    'MembershipRequestForm': MembershipRequestForm
    'MembershipModal': MembershipModal
    'ChangePasswordForm': ChangePasswordForm
    'PollCommonOutcomeModal': PollCommonOutcomeModal
    'PollCommonReopenModal': PollCommonReopenModal
    'ArrangementForm': ArrangementForm
    'AnnouncementForm': AnnouncementForm
    'AnnouncementHistory': AnnouncementHistory
    'MoveThreadForm': MoveThreadForm
    'PollCommonAddOptionModal': PollCommonAddOptionModal
    'RevisionHistoryModal': RevisionHistoryModal
    'TagsModal': TagsModal
    'InstallSlackModal': InstallSlackModal
    'InstallMicrosoftTeamsModal': InstallMicrosoftTeamsModal
    'ChangePictureForm': ChangePictureForm
    'GroupNewForm': GroupNewForm
    'PinEventForm': PinEventForm
    'MoveCommentsModal': MoveCommentsModal
    'SeenByModal': SeenByModal
    'ExportDataModal': ExportDataModal
    'VueUpgradedModal': VueUpgradedModal
    'InstallSamlProviderModal': InstallSamlProviderModal
    'GroupSurvey': GroupSurvey

  data: ->
    isOpen: false
    componentName: ""
    componentProps: {}
    maxWidth: 600

  created: ->
    EventBus.$on('openModal', @openModal)
    EventBus.$on('closeModal', @doCloseModal)

  methods:
    openModal: (opts) ->
      @maxWidth = opts.maxWidth || 600
      @isOpen = true
      @componentName = opts.component
      @componentProps = opts.props

    doCloseModal: -> @isOpen = false

    componentKey: ->
      date = new Date()
      date.getTime()


</script>

<template lang="pug">
v-dialog(v-model="isOpen" :max-width="maxWidth" persistent :fullscreen="$vuetify.breakpoint.xs")
  component(:is="componentName" :key="componentKey()" v-bind="componentProps" :close="closeModal")
</template>
