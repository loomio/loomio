<script lang="js">
import EventBus from "@/shared/services/event_bus";
import { defineAsyncComponent } from 'vue'

export default
{
  components: {
    GroupForm: defineAsyncComponent(() => import('@/components/group/form.vue')),
    DiscussionForm: defineAsyncComponent(() => import('@/components/discussion/form.vue')),
    EditCommentForm: defineAsyncComponent(() => import('@/components/thread/edit_comment_form.vue')),
    ConfirmModal: defineAsyncComponent(() => import('@/components/common/confirm_modal.vue')),
    InfoModal: defineAsyncComponent(() => import('@/components/common/info_modal.vue')),
    ArrangementForm: defineAsyncComponent(() => import('@/components/thread/arrangement_form.vue')),
    ChangeVolumeForm: defineAsyncComponent(() => import('@/components/common/change_volume_form')),
    PollCommonModal: defineAsyncComponent(() => import('@/components/poll/common/modal')),
    PollCommonEditVoteModal: defineAsyncComponent(() => import('@/components/poll/common/edit_vote_modal')),
    ContactRequestForm: defineAsyncComponent(() => import('@/components/contact/request_form')),
    AuthModal: defineAsyncComponent(() => import('@/components/auth/modal')),
    MembershipRequestForm: defineAsyncComponent(() => import('@/components/group/membership_request_form')),
    MembershipModal: defineAsyncComponent(() => import('@/components/group/membership_modal')),
    EmailToGroupSettings: defineAsyncComponent(() => import('@/components/group/email_to_group_settings')),
    MemberEmailAliasModal: defineAsyncComponent(() => import('@/components/group/member_email_alias_modal')),
    ChangePasswordForm: defineAsyncComponent(() => import('@/components/profile/change_password_form')),
    ChatbotList: defineAsyncComponent(() => import('@/components/chatbot/list')),
    ChatbotMatrixForm: defineAsyncComponent(() => import('@/components/chatbot/matrix_form')),
    ChatbotWebhookForm: defineAsyncComponent(() => import('@/components/chatbot/webhook_form')),
    PollCommonOutcomeModal: defineAsyncComponent(() => import('@/components/poll/common/outcome_modal')),
    PollCommonReopenModal: defineAsyncComponent(() => import('@/components/poll/common/reopen_modal')),
    PollOptionForm: defineAsyncComponent(() => import('@/components/poll/common/poll_option_form')),
    PollTemplateForm: defineAsyncComponent(() => import('@/components/poll_template/form')),
    MoveThreadForm: defineAsyncComponent(() => import('@/components/thread/move_thread_form')),
    PollCommonMoveForm: defineAsyncComponent(() => import('@/components/poll/common/move_form')),
    RevisionHistoryModal: defineAsyncComponent(() => import('@/components/revision_history/modal')),
    TagsSelect: defineAsyncComponent(() => import('@/components/tags/select')),
    TagsModal: defineAsyncComponent(() => import('@/components/tags/modal')),
    ChangePictureForm: defineAsyncComponent(() => import('@/components/profile/change_picture_form')),
    GroupNewForm: defineAsyncComponent(() => import('@/components/group/new_form')),
    PinEventForm: defineAsyncComponent(() => import('@/components/thread/pin_event_form')),
    MoveCommentsModal: defineAsyncComponent(() => import('@/components/discussion/move_comments_modal')),
    ExportDataModal: defineAsyncComponent(() => import('@/components/group/export_data_modal')),
    AddPollToThreadModal: defineAsyncComponent(() => import('@/components/poll/add_to_thread_modal')),
    StrandMembersList: defineAsyncComponent(() => import('@/components/strand/members_list')),
    SeenByModal: defineAsyncComponent(() => import('@/components/strand/seen_by_modal')),
    PollMembers: defineAsyncComponent(() => import('@/components/poll/members')),
    PollReminderForm: defineAsyncComponent(() => import('@/components/poll/reminder_form')),
    GroupInvitationForm: defineAsyncComponent(() => import('@/components/group/invitation_form')),
    AnnouncementHistory: defineAsyncComponent(() => import('@/components/common/announcement_history')),
    SearchModal: defineAsyncComponent(() => import('@/components/search/modal')),
    UserNameModal: defineAsyncComponent(() => import('@/components/group/user_name_modal')),
    RecordVideoModal: defineAsyncComponent(() => import('@/components/lmo_textarea/record_video_modal')),
    RecordAudioModal: defineAsyncComponent(() => import('@/components/lmo_textarea/record_audio_modal')),
  },

  data() {
    return {
      isOpen: false,
      componentName: "",
      componentProps: {},
      componentKey: 'defaultKey',
      maxWidth: null,
      persistent: true,
      scrollable: false
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
      this.scrollable = opts.scrollable || false;
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
v-dialog.modal-launcher(
  ref="modalLauncher"
  v-model="isOpen"
  :scrollable="scrollable"
  :max-width="maxWidth"
  :persistent="persistent"
  :fullscreen="$vuetify.display.xs")
  component(:is="componentName" :key="componentKey" v-bind="componentProps" :close="closeModal")
</template>
