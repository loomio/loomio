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
    model: Object
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
      key: this.model.id,
      collections: ['groups', 'memberships', 'polls'],
      query: () => {
        this.canAddComment = AbilityService.canAddComment(this.model);
      }
    });
    this.resetComment();
  },

  methods: {
    resetComment() {
      if (this.isDiscussion) {
        this.newComment = Records.comments.build({
          bodyFormat: Session.defaultFormat(),
          discussionId: this.model.id,
          authorId: Session.user().id
        });
      } else {
        this.newComment = Records.comments.build({
          bodyFormat: Session.defaultFormat(),
          parentType: 'Poll',
          parentId: this.model.id,
          authorId: Session.user().id
        });
      }
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
    'model.id'() {
      this.resetComment();
      this.resetPoll();
    }
  },

  computed: {
    isDiscussion() {
      return this.model.constructor.singular === 'discussion';
    },

    topicClosedAt() {
      const topic = this.model.topic ? this.model.topic() : null;
      return topic ? topic.closedAt : this.model.closedAt;
    },

    newestFirst() {
      const topic = this.model.topic ? this.model.topic() : null;
      return topic ? topic.newestFirst : false;
    },

    canStartPoll() {
      return this.isDiscussion && AbilityService.canStartPoll(this.model);
    },

    modelGroup() {
      return this.model.group ? this.model.group() : null;
    }
  }
};

</script>

<template lang="pug">
section.actions-panel#add-comment(:key="model.id" :class="{'mt-2 px-2 px-sm-4': !newestFirst}")
  template(v-if="isDiscussion && topicClosedAt")
    v-alert(type="info" variant="tonal")
      span(v-t="{path: 'notifications.without_title.discussion_closed', args: {actor: model.closer().name} }")
      mid-dot
      time-ago(:date='model.closedAt')
  template(v-if="canAddComment")
    v-divider(aria-hidden="true")
    v-tabs.activity-panel__actions.mb-3(grow color="primary" v-model="currentAction")
      v-tab(value='add-comment')
        span(v-t="'comment_form.add_a_comment'")
      v-tab.activity-panel__add-poll(value='add-poll' v-if="canStartPoll")
        span(v-t="'discussion_context.start_a_vote'")
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
            :discussion="model"
            :group="modelGroup")
  template(v-if="!topicClosedAt && !canAddComment")
    .add-comment-panel__join-actions.mb-2
      join-group-button(
        v-if='isLoggedIn() && modelGroup'
        :group='modelGroup'
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
