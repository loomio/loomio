<script setup lang="js">
import Records           from '@/shared/services/records';
import Session           from '@/shared/services/session';
import EventBus          from '@/shared/services/event_bus';
import TopicLoader       from '@/shared/loaders/topic_loader';
import TopicActionsPanel from '@/components/topic/actions_panel';
import ScrollService     from '@/shared/services/scroll_service';
import { useWatchRecords } from '@/composables/useWatchRecords';
import { ref, computed, onMounted, onUnmounted, watch, nextTick } from 'vue';
import { useRoute } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { mdiArrowDown } from '@mdi/js';

const route = useRoute();
const { t } = useI18n();
const { watchRecords } = useWatchRecords();

const topic            = ref(null);
const loadedKey        = ref(null);
const loader           = ref(null);
const focusSelector    = ref(null);
const anchorSelector   = ref(null);
const anchorOffset     = ref(null);
const lastAnchorSelector = ref(null);
const focusedItemVisible = ref(false);
const latestVisible = ref(false);
const jumping = ref(false);
const showLatest = computed(() => topic.value && topic.value.itemsCount > 1 && !latestVisible.value);
let pageGeneration = 0;
let cancelSettledAnchorScroll = null;

watchRecords({
  key: 'topic-page',
  collections: ['topic_items', 'polls', 'stances'],
  query: () => {
    if (!loader.value) return;
    loader.value.updateCollection();
    nextTick(scrollToAnchorIfNew);
  }
});

onMounted(() => {
  EventBus.$on('setAnchor', onSetAnchor);
  EventBus.$on('visibleKeys', onVisibleKeys);

  init();
});

onUnmounted(() => {
  EventBus.$off('setAnchor', onSetAnchor);
  EventBus.$off('visibleKeys', onVisibleKeys);
  cancelSettledScroll();
  pageGeneration += 1;
  loader.value = null;
  anchorSelector.value = null;
});

watch(() => route.params.key, init);
watch(() => route.params.sequence_id, respondToRoute);
watch(() => route.params.comment_id, respondToRoute);
watch(() => route.query.sequence_id, respondToRoute);
watch(() => route.query.comment_id, respondToRoute);
watch(() => route.query.p, respondToRoute);
watch(() => route.query.k, respondToRoute);
watch(() => route.query.current_action, respondToRoute);

function scrollToFocused() {
  if (focusSelector.value) {
    ScrollService.scrollTo(focusSelector.value, anchorOffset.value);
  }
}

function cancelSettledScroll() {
  if (cancelSettledAnchorScroll) {
    cancelSettledAnchorScroll();
    cancelSettledAnchorScroll = null;
  }
}

// Fired by load_more.vue before prepending items above the viewport.
// Stores the current top-visible item's selector + screen offset so
// scrollToAnchorIfNew can restore the visual position after insertion.
function onSetAnchor(selector, offset) {
  cancelSettledScroll();
  anchorSelector.value = selector;
  anchorOffset.value = offset;
}

function onVisibleKeys(keys) {
  if (topic.value) {
    const latest = Records.topicItems.find({topicId: topic.value.id, sequenceId: topic.value.lastSequenceId()})[0];
    latestVisible.value = !!latest && keys.includes(latest.positionKey);
  }
  if (!focusSelector.value || !loader.value) { return true; }

  const match = focusSelector.value.match(/\.sequenceId-(\d+)/);
  if (!match) { return true; }

  const sequenceId = parseInt(match[1]);
  const topic_item = Records.topicItems.find({ topicId: topic.value.id, sequenceId })[0];
  if (!topic_item) { return false; }
  focusedItemVisible.value = keys.includes(topic_item.positionKey);
}

function init() {
  cancelSettledScroll();
  pageGeneration += 1;
  topic.value = null;
  loadedKey.value = null;
  loader.value = null;
  focusSelector.value = null;
  anchorSelector.value = null;
  lastAnchorSelector.value = null;
  latestVisible.value = false;
  jumping.value = false;

  const records = route.path.startsWith('/p/') ? Records.polls : Records.discussions;
  const cached = records.findByKey(route.params.key);
  if (cached) displayTopic(cached.topic());
  fetchInitialContent();
}

function routeTopicParams() {
  return route.path.startsWith('/p/') ? { poll_key: route.params.key } : { discussion_key: route.params.key };
}

function hasRouteKey() {
  return !!route.params.key;
}

function routeSequenceId() {
  const p = parseInt(route.params.sequence_id);
  const q = parseInt(route.query.sequence_id);
  if (Number.isInteger(p)) { return p; }
  if (Number.isInteger(q)) { return q; }
  return null;
}

function hasSequenceId(sequenceId) {
  return Number.isInteger(sequenceId);
}

function routeCommentId() {
  return parseInt(route.query.comment_id || route.params.comment_id) || null;
}

// Render known records before refreshing. Ordinary opens start at the beginning;
// only explicit links and user actions move the viewport within the thread.
function displayTopic(record) {
  if (record.group().newHost) { window.location.host = record.group().newHost; }
  topic.value = record;
  loadedKey.value = route.params.key;
  loader.value = new TopicLoader(record);
  loadContent(routeTopicParams());
  loader.value.updateCollection();
  setAnchorFromRoute();
  publishTitle();
  const generation = pageGeneration;
  nextTick(() => {
    if (pageGeneration !== generation) return;
    if (anchorSelector.value) scrollToAnchorIfPresent();
    else window.scrollTo({top: 0, behavior: 'instant'});
  });
}

function publishTitle() {
  EventBus.$emit('currentComponent', {
    focusHeading: false,
    page: 'topicPage',
    topic: topic.value,
    group: topic.value.group(),
    title: topic.value.topicable().title
  });
}

function initialFetchParams() {
  const remoteTopicParams = {...routeTopicParams(), include_polls_not_closed: 1};
  const sequenceId = routeSequenceId();
  const commentId = routeCommentId();
  const padding = 25;

  if (hasSequenceId(sequenceId)) {
    return {
      ...remoteTopicParams,
      sequence_id_gte: Math.max(sequenceId - parseInt(padding / 2), 0),
      order: 'sequence_id',
      per: padding
    };
  }

  if (commentId) {
    return {
      ...remoteTopicParams,
      comment_id: commentId,
      order: 'sequence_id',
      per: padding
    };
  }

  const poll = route.path.startsWith('/p/') ? Records.polls.findByKey(route.params.key) : null;
  const embeddedOrUnknownPoll = route.path.startsWith('/p/') && (!poll || poll.id !== poll.topic().topicableId || poll.topic().topicableType !== 'Poll');
  return {
    ...remoteTopicParams,
    // The server resolves an embedded poll's position when its key is used.
    ...(embeddedOrUnknownPoll ? {unread_or_newest: 1} : {order_by: 'sequence_id'}),
    per: padding
  };
}

function fetchInitialContent() {
  if (!hasRouteKey()) { return; }

  const key = route.params.key;
  const generation = pageGeneration;
  const routeLocation = JSON.stringify([route.path, route.params, route.query]);
  const params = initialFetchParams();
  const initialLoader = loader.value;
  const initialRules = initialLoader ? initialLoader.rules.filter(rule => rule.remote) : null;

  return Records.topicItems.fetch({ params }).then(data => {
    if (pageGeneration !== generation || route.params.key !== key) { return; }
    if (JSON.stringify([route.path, route.params, route.query]) !== routeLocation) return;

    const topicId = (data.topics || [])[0]?.id || (data.topic_items || [])[0]?.topic_id;
    const t = Records.topics.find(topicId);
    if (!t) { return; }

    if (!topic.value) displayTopic(t);
    if (route.path.startsWith('/p/') && !focusSelector.value) {
      loadContent(routeTopicParams());
      setAnchorFromRoute();
      nextTick(scrollToAnchorIfNew);
    }
    const satisfiedRules = initialRules || loader.value.rules.filter(rule => rule.remote);
    // An unknown poll can resolve to a root poll. Its unread/newest response
    // does not satisfy the oldest window used for an ordinary thread open.
    loader.value.fetchedRules.push(...satisfiedRules.filter(rule => !params.unread_or_newest || rule.name !== 'oldest').map(rule => JSON.stringify(rule.remote)));
    loader.value.isFirstLoad = false;
    loader.value.updateCollection();
    publishTitle();
    if (params.unread_or_newest && !focusSelector.value) return refreshLoader();
  }).catch(error => {
    if (pageGeneration !== generation) return;
    if (error.status) {
      EventBus.$emit('pageError', error);
      if ((error.status === 403) && !Session.isSignedIn()) { EventBus.$emit('openAuthModal'); }
    } else {
      console.error(error);
    }
  });
}

function refreshLoader() {
  const currentLoader = loader.value;
  return currentLoader.fetch().then(() => {
    if (loader.value === currentLoader) currentLoader.updateCollection();
  }).catch(error => {
    if (loader.value === currentLoader && error.status) EventBus.$emit('pageError', error);
  });
}

async function jumpToLatest() {
  if (jumping.value) return;
  const currentLoader = loader.value;
  jumping.value = true;
  cancelSettledScroll();
  focusSelector.value = null;
  anchorSelector.value = null;
  currentLoader.addLoadNewestRule();
  currentLoader.updateCollection();
  const target = `.sequenceId-${currentLoader.topic.lastSequenceId()}`;
  const cached = Records.topicItems.find({topicId: currentLoader.topic.id, sequenceId: currentLoader.topic.lastSequenceId()}).length > 0;
  try {
    if (cached) {
      await nextTick();
      if (loader.value !== currentLoader) return;
      ScrollService.scrollTo(target);
    }
    await currentLoader.fetch();
    if (loader.value !== currentLoader) return;
    currentLoader.updateCollection();
    await nextTick();
    if (!cached) ScrollService.scrollTo(target);
  } catch (error) {
    if (loader.value === currentLoader && error.status) EventBus.$emit('pageError', error);
  } finally {
    if (loader.value === currentLoader) jumping.value = false;
  }
}

function loadContent(remoteTopicParams = null) {
  if (!topic.value) { return fetchInitialContent(); }
  if (loadedKey.value !== route.params.key) { return; }
  remoteTopicParams ||= { topic_id: topic.value.id };


  focusSelector.value = null;
  anchorSelector.value = null;
  anchorOffset.value  = null;

  loader.value.addLoadMyStuffRule();
  loader.value.addLoadPollsNotClosedRule();

  if (topic.value.itemsCount <= 1) {
    loader.value.addLoadNewestRule(remoteTopicParams);
    return;
  }

  if (route.path.startsWith('/p/')) {
    const poll = Records.polls.findByKey(route.params.key);
    if (poll && !(topic.value.topicableType === 'Poll' && topic.value.topicableId === poll.id)) {
      const topic_item = Records.topicItems.find({ topicId: topic.value.id, itemableType: 'Poll', itemableId: poll.id, kind: 'poll_created' })[0];
      if (topic_item) {
        loader.value.addLoadSequenceIdRule(topic_item.sequenceId, remoteTopicParams);
        focusSelector.value = `.sequenceId-${topic_item.sequenceId}`;
        return;
      }
    }
  }

  const sequenceId = routeSequenceId();
  if (hasSequenceId(sequenceId)) {
    loader.value.addLoadSequenceIdRule(sequenceId, remoteTopicParams);
    focusSelector.value = `.sequenceId-${sequenceId}`;
    return;
  }

  const commentId = routeCommentId();
  if (commentId) {
    loader.value.addLoadCommentRule(commentId, remoteTopicParams);
    focusSelector.value = `#comment-${commentId}`;
    return;
  }

  loader.value.addLoadOldestRule(remoteTopicParams);
}

function respondToRoute() {
  const load = loadContent();
  if (load) { return load; }

  setAnchorFromRoute();

  scrollToAnchorIfPresent();
  loader.value.updateCollection();
  refreshLoader();
}

function setAnchorFromRoute() {
  if (route.query.current_action) {
    anchorSelector.value = '.actions-panel-end';
  } else if (!anchorSelector.value) {
    anchorSelector.value = focusSelector.value;
    anchorOffset.value = null;
  }
}

function scrollToAnchorIfPresent() {
  if (!anchorSelector.value) { return; }

  if (shouldSettleAnchorScroll()) {
    cancelSettledScroll();
    cancelSettledAnchorScroll = ScrollService.scrollToSettled(anchorSelector.value, anchorOffset.value);
  } else if (document.querySelector(anchorSelector.value)) {
    ScrollService.scrollTo(anchorSelector.value, anchorOffset.value);
  }
  lastAnchorSelector.value = anchorSelector.value;
}

function scrollToAnchorIfNew() {
  if (anchorSelector.value && lastAnchorSelector.value !== anchorSelector.value) {
    if (shouldSettleAnchorScroll()) {
      cancelSettledScroll();
      cancelSettledAnchorScroll = ScrollService.scrollToSettled(anchorSelector.value, anchorOffset.value);
    } else {
      ScrollService.scrollTo(anchorSelector.value, anchorOffset.value);
    }
    lastAnchorSelector.value = anchorSelector.value;
  }
}

function shouldSettleAnchorScroll() {
  return anchorSelector.value && (
    anchorSelector.value === focusSelector.value ||
    anchorSelector.value === '.actions-panel-end'
  );
}
</script>

<template lang="pug">
.topic-page
  v-main
    v-container.max-width-800.px-0.px-sm-3.pb-0.pb-md-4#topic-page(v-if="topic")
      plan-banner(v-if="topic.groupId" :group="topic.group()")
      discussion-fork-actions(v-if="topic" :topic='topic' :key="'fork-actions'+ topic.id")
      v-sheet.topic-card.mb-0.mb-md-8.pb-4.rounded-lg
        .topic-page__cached-context.sequenceId-0.pa-3#context(v-if="!loader.collection.length")
          topic-header(:topicable="topic.topicable()")
          formatted-text(:model="topic.topicable()" :field="topic.topicableType === 'Discussion' ? 'description' : 'details'")
          attachment-list(:attachments="topic.topicable().attachments")
        topic-list.pr-1.pr-sm-3.px-sm-2(:loader="loader" :collection="loader.collection" :focus-selector="focusSelector")
        topic-actions-panel(:topic="topic")
    .topic-page__latest.lmo-no-print(v-if="showLatest")
      v-btn(rounded color="info" :prepend-icon="mdiArrowDown" :loading="jumping" @click="jumpToLatest") {{ t('strand_nav.latest') }}
  topic-toc-nav(v-if="loader" :topic="topic" :loader="loader" :key="topic.id")
</template>

<style>
.topic-page__latest {
  position: fixed;
  bottom: calc(var(--v-layout-bottom, 0px) + 16px);
  left: 50%;
  transform: translateX(-50%);
  z-index: 5;
}
</style>
