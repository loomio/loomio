<script lang="js">
import AppConfig                from '@/shared/services/app_config';
import EventBus                 from '@/shared/services/event_bus';
import RecordLoader             from '@/shared/services/record_loader';
import AbilityService           from '@/shared/services/ability_service';
import PollCommonForm from '@/components/poll/common/form';
import PollCommonChooseTemplateWrapper from '@/components/poll/common/choose_template_wrapper';
import Session from '@/shared/services/session';
import AuthModalMixin from '@/mixins/auth_modal';
import Records from '@/shared/services/records';

export default {
  components: {PollCommonForm, PollCommonChooseTemplateWrapper},
  mixins: [ AuthModalMixin ],

  props: {
    discussion: Object
  },

  data() {
    return {
      canAddComment: false,
      currentAction: 'add-comment',
      newComment: null,
      poll: null
    };
  },
    // showDecisionBadge: false

  created() {
  
    this.watchRecords({
      key: this.discussion.id,
      collections: ['groups', 'memberships', 'polls'],
      query: store => {
        return this.canAddComment = AbilityService.canAddComment(this.discussion);
      }
    });
    this.resetComment();
  },

  methods: {
    // resetBadge: ->
    //   if @canStartPoll && @discussion.discussionTemplateId && @discussion.activePolls().length == 0
    //     @showDecisionBadge = true

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

<template>

<section class="actions-panel" id="add-comment" :key="discussion.id" :class="{'mt-2 px-2 px-sm-4': !discussion.newestFirst}">
  <template v-if="discussion.closedAt">
    <v-alert type="info" text="text" outlined="outlined"><span v-t="{path: 'notifications.without_title.discussion_closed', args: {actor: discussion.closer().name} }"></span>
      <mid-dot></mid-dot>
      <time-ago :date="discussion.closedAt"></time-ago>
    </v-alert>
  </template>
  <template v-else>
    <v-divider aria-hidden="true"></v-divider>
    <v-tabs class="activity-panel__actions mb-3" grow="grow" text="text" v-model="currentAction">
      <v-tabs-slider></v-tabs-slider>
      <v-tab href="#add-comment"><span v-t="'thread_context.add_comment'"></span></v-tab>
      <v-tab class="activity-panel__add-poll" href="#add-poll" v-if="canStartPoll"><span v-t="'poll_common.decision'"></span></v-tab>
    </v-tabs>
    <v-tabs-items v-model="currentAction">
      <v-tab-item value="add-comment">
        <div class="add-comment-panel">
          <comment-form v-if="canAddComment" :comment="newComment" @comment-submitted="resetComment"></comment-form>
          <div class="add-comment-panel__join-actions" v-if="!canAddComment">
            <join-group-button v-if="isLoggedIn()" :group="discussion.group()" :block="true"></join-group-button>
            <v-btn class="add-comment-panel__sign-in-btn" v-t="'comment_form.sign_in'" @click="signIn()" v-if="!isLoggedIn()"></v-btn>
          </div>
        </div>
      </v-tab-item>
      <v-tab-item value="add-poll" v-if="canStartPoll">
        <div class="poll-common-start-form">
          <poll-common-form v-if="poll" :poll="poll" @setPoll="setPoll" @saveSuccess="resetPoll"></poll-common-form>
          <poll-common-choose-template-wrapper v-if="!poll" @setPoll="setPoll" :discussion="discussion" :group="discussion.group()"></poll-common-choose-template-wrapper>
        </div>
      </v-tab-item>
    </v-tabs-items>
  </template>
</section>
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
