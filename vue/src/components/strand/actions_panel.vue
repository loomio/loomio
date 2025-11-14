<script setup lang="js">
import { ref, computed, watch, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import AbilityService from '@/shared/services/ability_service';
import PollCommonForm from '@/components/poll/common/form';
import PollCommonChooseTemplateWrapper from '@/components/poll/common/choose_template_wrapper';
import Session from '@/shared/services/session';
import Records from '@/shared/services/records';
import { useWatchRecords } from '@/shared/composables/use_watch_records';
import { useAuthModal } from '@/shared/composables/use_auth_modal';

const props = defineProps({
  discussion: Object
});

const route = useRoute();

const canAddComment = ref(false);
const currentAction = ref(route.query.current_action == "add-poll" ? 'add-poll' : 'add-comment');
const newComment = ref(null);
const poll = ref(null);
const { watchRecords } = useWatchRecords();
const { openAuthModal } = useAuthModal();

const canStartPoll = computed(() => {
  return AbilityService.canStartPoll(props.discussion);
});

const resetComment = () => {
  newComment.value = Records.comments.build({
    bodyFormat: Session.defaultFormat(),
    discussionId: props.discussion.id,
    authorId: Session.user().id
  });
};

const setPoll = (pollValue) => {
  poll.value = pollValue;
};

const resetPoll = () => {
  poll.value = null;
  currentAction.value = 'add-comment';
};

const signIn = () => {
  openAuthModal();
};

const isLoggedIn = () => {
  return Session.isSignedIn();
};

onMounted(() => {
  watchRecords({
    key: props.discussion.id,
    collections: ['groups', 'memberships', 'polls'],
    query: () => {
      canAddComment.value = AbilityService.canAddComment(props.discussion);
    }
  });
  resetComment();
});

watch(() => route.query.current_action, (val) => {
  currentAction.value = (val == "add-poll" ? 'add-poll' : 'add-comment');
});

watch(() => props.discussion.id, () => {
  resetComment();
  resetPoll();
});
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
        span(v-t="'thread_context.add_comment'")
      v-tab.activity-panel__add-poll(value='add-poll' v-if="canStartPoll")
        span(v-t="'poll_common.decision'")
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