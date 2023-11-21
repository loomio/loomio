<script lang="js">
import EventBus from "@/shared/services/event_bus";

export default
{
  components: {
    GroupForm: () => import('@/components/group/form.vue'),
    DiscussionForm: () => import('@/components/discussion/form.vue'),
    EditCommentForm: () => import('@/components/thread/edit_comment_form.vue'),
    ConfirmModal: () => import('@/components/common/confirm_modal.vue'),
    ArrangementForm: () => import('@/components/thread/arrangement_form.vue'),
    ChangeVolumeForm: () => import('@/components/common/change_volume_form'),
    PollCommonModal: () => import('@/components/poll/common/modal'),
    PollCommonEditVoteModal: () => import('@/components/poll/common/edit_vote_modal'),
    ContactRequestForm: () => import('@/components/contact/request_form'),
    AuthModal: () => import('@/components/auth/modal'),
    MembershipRequestForm: () => import('@/components/group/membership_request_form'),
    MembershipModal: () => import('@/components/group/membership_modal'),
    EmailToGroupSettings: () => import('@/components/group/email_to_group_settings'),
    ChangePasswordForm: () => import('@/components/profile/change_password_form'),
    ChatbotList: () => import('@/components/chatbot/list'),
    ChatbotMatrixForm: () => import('@/components/chatbot/matrix_form'),
    ChatbotWebhookForm: () => import('@/components/chatbot/webhook_form'),
    PollCommonOutcomeModal: () => import('@/components/poll/common/outcome_modal'),
    PollCommonReopenModal: () => import('@/components/poll/common/reopen_modal'),
    PollOptionForm: () => import('@/components/poll/common/poll_option_form'),
    PollTemplateForm: () => import('@/components/poll_template/form'),
    MoveThreadForm: () => import('@/components/thread/move_thread_form'),
    PollCommonMoveForm: () => import('@/components/poll/common/move_form'),
    RevisionHistoryModal: () => import('@/components/revision_history/modal'),
    TagsSelect: () => import('@/components/tags/select'),
    TagsModal: () => import('@/components/tags/modal'),
    WebhookForm: () => import('@/components/webhook/form'),
    WebhookList: () => import('@/components/webhook/list'),
    ChangePictureForm: () => import('@/components/profile/change_picture_form'),
    GroupNewForm: () => import('@/components/group/new_form'),
    PinEventForm: () => import('@/components/thread/pin_event_form'),
    MoveCommentsModal: () => import('@/components/discussion/move_comments_modal'),
    ExportDataModal: () => import('@/components/group/export_data_modal'),
    AddPollToThreadModal: () => import('@/components/poll/add_to_thread_modal'),
    StrandMembersList: () => import('@/components/strand/members_list'),
    SeenByModal: () => import('@/components/strand/seen_by_modal'),
    PollMembers: () => import('@/components/poll/members'),
    PollReminderForm: () => import('@/components/poll/reminder_form'),
    GroupInvitationForm: () => import('@/components/group/invitation_form'),
    AnnouncementHistory: () => import('@/components/common/announcement_history'),
    SearchModal: () => import('@/components/search/modal'),
    UserNameModal: () => import('@/components/group/user_name_modal'),
    RecordVideoModal: () => import('@/components/lmo_textarea/record_video_modal'),
    RecordAudioModal: () => import('@/components/lmo_textarea/record_audio_modal'),
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
