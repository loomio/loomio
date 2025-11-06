<script lang="js">
import EventBus from "@/shared/services/event_bus";
import asyncComponent from '@/shared/services/async_component'

export default
{
  components: {
    GroupForm: asyncComponent(() => import('@/components/group/form.vue')),
    DiscussionForm: asyncComponent(() => import('@/components/discussion/form.vue')),
    EditCommentForm: asyncComponent(() => import('@/components/thread/edit_comment_form.vue')),
    ConfirmModal: asyncComponent(() => import('@/components/common/confirm_modal.vue')),
    InfoModal: asyncComponent(() => import('@/components/common/info_modal.vue')),
    ArrangementForm: asyncComponent(() => import('@/components/thread/arrangement_form.vue')),
    ChangeVolumeForm: asyncComponent(() => import('@/components/common/change_volume_form')),
    PollCommonModal: asyncComponent(() => import('@/components/poll/common/modal')),
    PollCommonEditVoteModal: asyncComponent(() => import('@/components/poll/common/edit_vote_modal')),
    AuthModal: asyncComponent(() => import('@/components/auth/modal')),
    MembershipRequestForm: asyncComponent(() => import('@/components/group/membership_request_form')),
    MembershipModal: asyncComponent(() => import('@/components/group/membership_modal')),
    EmailToGroupSettings: asyncComponent(() => import('@/components/group/email_to_group_settings')),
    MemberEmailAliasModal: asyncComponent(() => import('@/components/group/member_email_alias_modal')),
    ChangePasswordForm: asyncComponent(() => import('@/components/profile/change_password_form')),
    ChatbotList: asyncComponent(() => import('@/components/chatbot/list')),
    ChatbotMatrixForm: asyncComponent(() => import('@/components/chatbot/matrix_form')),
    ChatbotWebhookForm: asyncComponent(() => import('@/components/chatbot/webhook_form')),
    PollCommonOutcomeModal: asyncComponent(() => import('@/components/poll/common/outcome_modal')),
    PollCommonReopenModal: asyncComponent(() => import('@/components/poll/common/reopen_modal')),
    PollOptionForm: asyncComponent(() => import('@/components/poll/common/poll_option_form')),
    PollTemplateForm: asyncComponent(() => import('@/components/poll_template/form')),
    MoveThreadForm: asyncComponent(() => import('@/components/thread/move_thread_form')),
    PollCommonMoveForm: asyncComponent(() => import('@/components/poll/common/move_form')),
    RevisionHistoryModal: asyncComponent(() => import('@/components/revision_history/modal')),
    TagsSelect: asyncComponent(() => import('@/components/tags/select')),
    TagsModal: asyncComponent(() => import('@/components/tags/modal')),
    ChangePictureForm: asyncComponent(() => import('@/components/profile/change_picture_form')),
    GroupNewForm: asyncComponent(() => import('@/components/group/new_form')),
    PinEventForm: asyncComponent(() => import('@/components/thread/pin_event_form')),
    MoveCommentsModal: asyncComponent(() => import('@/components/discussion/move_comments_modal')),
    ExportDataModal: asyncComponent(() => import('@/components/group/export_data_modal')),
    AddPollToThreadModal: asyncComponent(() => import('@/components/poll/add_to_thread_modal')),
    StrandMembersList: asyncComponent(() => import('@/components/strand/members_list')),
    SeenByModal: asyncComponent(() => import('@/components/strand/seen_by_modal')),
    PollMembers: asyncComponent(() => import('@/components/poll/members')),
    PollReminderForm: asyncComponent(() => import('@/components/poll/reminder_form')),
    GroupInvitationForm: asyncComponent(() => import('@/components/group/invitation_form')),
    GroupShareableLinkForm: asyncComponent(() => import('@/components/group/shareable_link_form')),
    AnnouncementHistory: asyncComponent(() => import('@/components/common/announcement_history')),
    SearchModal: asyncComponent(() => import('@/components/search/modal')),
    UserNameModal: asyncComponent(() => import('@/components/group/user_name_modal')),
    RecordVideoModal: asyncComponent(() => import('@/components/lmo_textarea/record_video_modal')),
    RecordAudioModal: asyncComponent(() => import('@/components/lmo_textarea/record_audio_modal')),
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
