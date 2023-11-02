<script lang="js">
import EventBus from "@/shared/services/event_bus";
import GroupForm from '@/components/group/form.vue';
import DiscussionForm from '@/components/discussion/form.vue';
import EditCommentForm from '@/components/thread/edit_comment_form.vue';
import ConfirmModal from '@/components/common/confirm_modal.vue';
import ArrangementForm from '@/components/thread/arrangement_form.vue';
import ChangeVolumeForm from '@/components/common/change_volume_form';
import PollCommonModal from '@/components/poll/common/modal';
import PollCommonEditVoteModal from '@/components/poll/common/edit_vote_modal';
import ContactRequestForm from '@/components/contact/request_form';
import AuthModal from '@/components/auth/modal';
import MembershipRequestForm from '@/components/group/membership_request_form';
import MembershipModal from '@/components/group/membership_modal';
import EmailToGroupSettings from '@/components/group/email_to_group_settings';
import ChangePasswordForm from '@/components/profile/change_password_form';
import ChatbotList from '@/components/chatbot/list';
import ChatbotMatrixForm from '@/components/chatbot/matrix_form';
import ChatbotWebhookForm from '@/components/chatbot/webhook_form';
import PollCommonOutcomeModal from '@/components/poll/common/outcome_modal';
import PollCommonReopenModal from '@/components/poll/common/reopen_modal';
import PollOptionForm from '@/components/poll/common/poll_option_form';
import PollTemplateForm from '@/components/poll_template/form';
import MoveThreadForm from '@/components/thread/move_thread_form';
import PollCommonMoveForm from '@/components/poll/common/move_form';
import RevisionHistoryModal from '@/components/revision_history/modal';
import TagsSelect from '@/components/tags/select';
import TagsModal from '@/components/tags/modal';
import WebhookForm from '@/components/webhook/form';
import WebhookList from '@/components/webhook/list';
import ChangePictureForm from '@/components/profile/change_picture_form';
import GroupNewForm from '@/components/group/new_form';
import PinEventForm from '@/components/thread/pin_event_form';
import MoveCommentsModal from '@/components/discussion/move_comments_modal';
import ExportDataModal from '@/components/group/export_data_modal';
import AddPollToThreadModal from '@/components/poll/add_to_thread_modal';
import StrandMembersList from '@/components/strand/members_list';
import SeenByModal from '@/components/strand/seen_by_modal';
import PollMembers from '@/components/poll/members';
import PollReminderForm from '@/components/poll/reminder_form';
import GroupInvitationForm from '@/components/group/invitation_form';
import AnnouncementHistory from '@/components/common/announcement_history';
import SearchModal from '@/components/search/modal';
import UserNameModal from '@/components/group/user_name_modal';
import RecordVideoModal from '@/components/lmo_textarea/record_video_modal';
import RecordAudioModal from '@/components/lmo_textarea/record_audio_modal';

export default
{
  components: {
    AnnouncementHistory,
    GroupForm,
    DiscussionForm,
    EditCommentForm,
    ConfirmModal,
    ChangeVolumeForm,
    ChatbotList,
    ChatbotMatrixForm,
    ChatbotWebhookForm,
    EmailToGroupSettings,
    PollCommonModal,
    PollCommonEditVoteModal,
    ContactRequestForm,
    AuthModal,
    MembershipRequestForm,
    MembershipModal,
    ChangePasswordForm,
    PollCommonOutcomeModal,
    PollCommonReopenModal,
    PollCommonMoveForm,
    PollOptionForm,
    MoveThreadForm,
    RevisionHistoryModal,
    PollTemplateForm,
    TagsModal,
    TagsSelect,
    WebhookForm,
    WebhookList,
    ChangePictureForm,
    GroupNewForm,
    PinEventForm,
    MoveCommentsModal,
    ExportDataModal,
    AddPollToThreadModal,
    StrandMembersList,
    PollMembers,
    PollReminderForm,
    GroupInvitationForm,
    SeenByModal,
    ArrangementForm,
    SearchModal,
    UserNameModal,
    RecordVideoModal,
    RecordAudioModal
  },

  data() {
    return {
      isOpen: false,
      componentName: "",
      componentProps: {},
      componentKey: 'defaultKey',
      maxWidth: null,
      persistent: true
    };
  },

  created() {
    EventBus.$on('openModal', this.openModal);
    EventBus.$on('closeModal', this.closeModal);
  },

  destroyed() {
    EventBus.$off('openModal', this.openModal);
    EventBus.$off('closeModal', this.closeModal);
  },

  methods: {
    openModal(opts) {
      if (opts.hasOwnProperty('persistent')) {
        this.persistent = opts.persistent; 
      }
      this.maxWidth = opts.maxWidth || 720;
      this.componentName = opts.component;
      this.componentProps = opts.props;
      this.componentKey = (new Date()).getTime();
      this.isOpen = true;

      return setTimeout(() => {
        if (this.$refs.modalLauncher && document.querySelector('.modal-launcher h1')) {
          document.querySelector('.modal-launcher h1').focus();
        }
      });
    },

    closeModal() {
      if (this.isOpen && (this.componentProps || {}).close) {
        this.componentProps.close();
      } else {
        this.isOpen = false;
      }
    }
  }
};

</script>

<template lang="pug">
v-dialog.modal-launcher(ref="modalLauncher" v-model="isOpen" :max-width="maxWidth" :persistent="persistent" :fullscreen="$vuetify.breakpoint.xs")
  v-card(v-if="isOpen")
    component(:is="componentName" :key="componentKey" v-bind="componentProps" :close="closeModal")
</template>
