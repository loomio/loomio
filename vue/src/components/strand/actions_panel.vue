<script setup>
import { ref, computed, watch, onUnmounted } from 'vue';
import { useRoute } from 'vue-router';
import AbilityService from '@/shared/services/ability_service';
import PollCommonForm from '@/components/poll/common/form';
import PollCommonChooseTemplateWrapper from '@/components/poll/common/choose_template_wrapper';
import Session from '@/shared/services/session';
import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import { useWatchRecords } from '@/composables/useWatchRecords';

const { topic } = defineProps({
  topic: { type: Object, required: true }
});

const route = useRoute();
const { watchRecords } = useWatchRecords();

const canAddComment = ref(false);
const canStartPoll = ref(false);
const forceShowCommentForm = ref(false);
const currentAction = ref(route.query.current_action == 'add-poll' ? 'add-poll' : 'add-comment');
const newComment = ref(null);
const poll = ref(null);

const resetComment = () => {
  newComment.value = Records.comments.build({
    bodyFormat: Session.defaultFormat(),
    parentType: topic.topicableType,
    parentId: topic.topicableId,
    authorId: Session.user().id
  });
};

const setPoll = (p) => { poll.value = p; };
const resetPoll = () => {
  poll.value = null;
  currentAction.value = 'add-comment';
};

const signIn = () => EventBus.$emit('openModal', { component: 'AuthModal', props: { preventClose: false } });
const isLoggedIn = () => Session.isSignedIn();

const showAddCommentForm = computed(() => {
  if (!canAddComment.value) return false;
  if (forceShowCommentForm.value) return true;
  if (topic.topicableType === 'Poll') {
    const p = topic.topicable();
    return !p || p.closedAt || p.iHaveVoted();
  }
  return true;
});

watch(() => route.query.current_action, (val) => {
  currentAction.value = val == 'add-poll' ? 'add-poll' : 'add-comment';
});

watch(() => topic.id, () => {
  resetComment();
  resetPoll();
});

watchRecords({
  key: topic.id,
  collections: ['topics', 'groups', 'memberships', 'polls', 'stances'],
  query: () => {
    canAddComment.value = AbilityService.canAddComment(topic);
    canStartPoll.value = AbilityService.canStartPoll(topic);
  }
});

resetComment();

EventBus.$on('show-add-comment-form', () => { forceShowCommentForm.value = true; currentAction.value = 'add-comment'; });
EventBus.$on('show-add-poll-form', () => { currentAction.value = 'add-poll'; });

onUnmounted(() => {
  EventBus.$off('show-add-comment-form');
  EventBus.$off('show-add-poll-form');
});
</script>

<template lang="pug">
section.actions-panel#add-comment(:key="topic.id" :class="{'mt-2 px-2 px-sm-4': !topic.newestFirst}")
  template(v-if="topic.closedAt")
    v-alert(prepend-icon="mdi-lock" variant="tonal")
      span(v-t="{path: 'notifications.without_title.discussion_closed', args: {actor: topic.closer().name} }")
      mid-dot
      time-ago(:date='topic.closedAt')
  template(v-if="showAddCommentForm")
    .add-comment-panel.pt-4(v-if="!canStartPoll")
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
