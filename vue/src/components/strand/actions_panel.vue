<script lang="js">
import AbilityService           from '@/shared/services/ability_service';
import PollCommonForm from '@/components/poll/common/form';
import PollCommonChooseTemplateWrapper from '@/components/poll/common/choose_template_wrapper';
import Session from '@/shared/services/session';
import AuthModalMixin from '@/mixins/auth_modal';
import Records from '@/shared/services/records';
import WatchRecords from '@/mixins/watch_records';
import EventBus from '@/shared/services/event_bus';

export default {
  components: {PollCommonForm, PollCommonChooseTemplateWrapper},
  mixins: [ AuthModalMixin, WatchRecords ],

  props: {
    topic: {
      type: Object,
      required: true
    }
  },

  data() {
    return {
      canAddComment: false,
      forceShowCommentForm: false,
      currentAction: this.$route.query.current_action == "add-poll" ? 'add-poll' : 'add-comment',
      newComment: null,
      poll: null
    };
  },

  created() {
    this.watchRecords({
      key: this.topic.id,
      collections: ['topics', 'groups', 'memberships', 'polls', 'stances'],
      query: () => {
        this.canAddComment = AbilityService.canAddComment(this.topic);
      }
    });
    this.resetComment();
    EventBus.$on('show-add-comment-form', () => { this.forceShowCommentForm = true; this.currentAction = 'add-comment'; });
    EventBus.$on('show-add-poll-form', () => { this.currentAction = 'add-poll'; });
  },

  methods: {
    resetComment() {
      this.newComment = Records.comments.build({
        bodyFormat: Session.defaultFormat(),
        parentType: this.topic.topicableType,
        parentId: this.topic.topicableId,
        authorId: Session.user().id
      })
    },

    setPoll(poll) { return this.poll = poll; },
    resetPoll() {
      this.poll = null;
      this.currentAction = 'add-comment';
    },

    signIn() { this.openAuthModal(); },
    isLoggedIn() { return Session.isSignedIn(); }
  },

  watch: {
    '$route.query.current_action'(val) {
      this.currentAction = (val == "add-poll" ? 'add-poll' : 'add-comment')
    },
    'topic.id'() {
      this.resetComment();
      this.resetPoll();
    }
  },

  computed: {
    canStartPoll() {
      return AbilityService.canStartPoll(this.topic);
    },
    showAddCommentForm() {
      if (!this.canAddComment) { return false; }
      if (this.forceShowCommentForm) { return true; }
      if (this.topic.topicableType === 'Poll') {
        const poll = this.topic.topicable();
        return !poll || poll.closedAt || poll.iHaveVoted();
      }
      return true;
    },
  }
};

</script>

<template lang="pug">
section.actions-panel#add-comment(:key="topic.id" :class="{'mt-2 px-2 px-sm-4': !topic.newestFirst}")
  template(v-if="topic.closedAt")
    v-alert(type="info" variant="tonal")
      span(v-t="{path: 'notifications.without_title.discussion_closed', args: {actor: topic.closer().name} }")
      mid-dot
      time-ago(:date='topic.closedAt')
  template(v-if="showAddCommentForm")
    v-divider(aria-hidden="true")
    .add-comment-panel.mt-4(v-if="!canStartPoll")
      comment-form(
        :comment="newComment"
        @comment-submitted="resetComment")
    template(v-else)
      v-tabs.activity-panel__actions.mb-3(grow color="primary" v-model="currentAction")
        v-tab(value='add-comment')
          span(v-t="'comment_form.add_a_comment'")
        v-tab.activity-panel__add-poll(value='add-poll')
          span(v-t="'discussion_context.start_a_vote'")
      v-window(v-model="currentAction")
        v-window-item(value="add-comment")
          .add-comment-panel
            comment-form(
              :comment="newComment"
              @comment-submitted="resetComment")
        v-window-item(value="add-poll")
          .poll-common-start-form
            poll-common-form(
              v-if="poll"
              :poll="poll"
              @setPoll="setPoll"
              @saveSuccess="resetPoll")
            poll-common-choose-template-wrapper(
              v-if="!poll"
              @setPoll="setPoll"
              :topic="topic"
            )
  template(v-if="!topic.closedAt && !canAddComment")
    .add-comment-panel__join-actions.mb-2
      join-group-button(
        v-if='isLoggedIn() && topic.group()'
        :group='topic.group()'
      )
      v-btn.add-comment-panel__sign-in-btn(
        variant="tonal"
        color="primary"
        @click='signIn()'
        v-if='!isLoggedIn()'
      )
        span(v-t="'comment_form.sign_in'")
  .actions-panel-end

</template>

<style lang="sass">
#add-comment .v-window
  overflow: visible

.add-comment-panel__sign-in-btn
  width: 100%
.add-comment-panel__join-actions
  button
    width: 100%

</style>
