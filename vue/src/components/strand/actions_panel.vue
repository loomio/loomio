<script lang="js">
import AbilityService           from '@/shared/services/ability_service';
import PollCommonForm from '@/components/poll/common/form';
import PollCommonChooseTemplateWrapper from '@/components/poll/common/choose_template_wrapper';
import Session from '@/shared/services/session';
import AuthModalMixin from '@/mixins/auth_modal';
import Records from '@/shared/services/records';
import WatchRecords from '@/mixins/watch_records';

export default {
  components: {PollCommonForm, PollCommonChooseTemplateWrapper},
  mixins: [ AuthModalMixin, WatchRecords ],

  props: {
    discussion: Object
  },

  data() {
    return {
      canAddComment: false,
      currentAction: this.$route.query.current_action == "add-poll" ? 'add-poll' : 'add-comment',
      newComment: null,
      poll: null
    };
  },

  created() {
    this.watchRecords({
      key: this.discussion.id,
      collections: ['groups', 'memberships', 'polls'],
      query: () => {
        this.canAddComment = AbilityService.canAddComment(this.discussion);
      }
    });
    this.resetComment();
  },

  methods: {
    resetComment() {
      this.newComment = Records.comments.build({
        bodyFormat: Session.defaultFormat(),
        discussionId: this.discussion.id,
        authorId: Session.user().id
      });
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
    'discussion.id'() {
      this.resetComment();
      this.resetPoll();
    }
  },

  computed: {
    canStartPoll() {
      return AbilityService.canStartPoll(this.discussion);
    }
  }
};

</script>

<template lang="pug">
section.actions-panel#add-comment(:key="discussion.id" :class="{'mt-2 px-2 px-sm-4': !discussion.newestFirst}")
  template(v-if="discussion.closedAt")
    v-alert(type="info" variant="tonal")
      span(v-t="{path: 'notifications.without_title.discussion_closed', args: {actor: discussion.closer().name} }")
      mid-dot
      time-ago(:date='discussion.closedAt')
  template(v-if="canAddComment")
    v-divider(aria-hidden="true")
    v-tabs.activity-panel__actions.mb-3(grow color="primary" v-model="currentAction")
      v-tab(value='add-comment')
        span(v-t="'thread_context.add_a_comment'")
      v-tab.activity-panel__add-poll(value='add-poll' v-if="canStartPoll")
        span(v-t="'thread_context.start_a_vote'")
    v-window(v-model="currentAction")
      v-window-item(value="add-comment")
        .add-comment-panel
          comment-form(
            :comment="newComment"
            @comment-submitted="resetComment")
      v-window-item(value="add-poll" v-if="canStartPoll")
        .poll-common-start-form
          poll-common-form(
            v-if="poll"
            :poll="poll"
            @setPoll="setPoll"
            @saveSuccess="resetPoll")
          poll-common-choose-template-wrapper(
            v-if="!poll"
            @setPoll="setPoll"
            :discussion="discussion"
            :group="discussion.group()")
  template(v-if="!discussion.closedAt && !canAddComment")
    .add-comment-panel__join-actions.mb-2
      join-group-button(
        v-if='isLoggedIn()'
        :group='discussion.group()'
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
