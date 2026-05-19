<script setup lang="js">
import Records           from '@/shared/services/records';
import Session           from '@/shared/services/session';
import EventBus          from '@/shared/services/event_bus';
import ThreadLoader      from '@/shared/loaders/thread_loader';
import StrandActionsPanel from './actions_panel';
import ScrollService     from '@/shared/services/scroll_service';
import { useWatchRecords } from '@/composables/useWatchRecords';
import { ref, onMounted, onUnmounted, watch, nextTick } from 'vue';
import { useRoute } from 'vue-router';
import { mdiMenuOpen } from '@mdi/js';

const route = useRoute();
const { watchRecords } = useWatchRecords();

const topic            = ref(null);
const loadedKey        = ref(null);
const loader           = ref(null);
const requestId        = ref(0);
const focusMode        = ref(null);
const focusSelector    = ref(null);
const anchorSelector   = ref(null);
const anchorOffset     = ref(null);
const lastAnchorSelector = ref(null);
const snackbar         = ref(false);
const focusedItemVisible = ref(false);

onMounted(() => {
  EventBus.$on('setAnchor', onSetAnchor);
  EventBus.$on('visibleKeys', onVisibleKeys);

  init();
});

onUnmounted(() => {
  EventBus.$off('setAnchor', onSetAnchor);
  EventBus.$off('visibleKeys', onVisibleKeys);
});

watch(() => route.params.key, init);
watch(() => route.params.sequence_id, respondToRoute);
watch(() => route.params.comment_id, respondToRoute);
watch(() => route.query.p, respondToRoute);
watch(() => route.query.k, respondToRoute);
watch(() => route.query.current_action, respondToRoute);
watch(() => route.query.unread, respondToRoute);
watch(() => route.query.newest, respondToRoute);

function openThreadNav() {
  EventBus.$emit('toggleThreadNav');
}

function scrollToFocused() {
  if (focusSelector.value) {
    ScrollService.scrollTo(focusSelector.value, anchorOffset.value);
  }
}

function onSetAnchor(selector, offset) {
  anchorSelector.value = selector;
  anchorOffset.value = offset;
}

function onVisibleKeys(keys) {
  if (!focusSelector.value || !loader.value) { return true; }

  const match = focusSelector.value.match(/\.sequenceId-(\d+)/);
  if (!match) { return true; }

  const sequenceId = parseInt(match[1]);
  const event = Records.events.find({ topicId: topic.value.id, sequenceId })[0];
  if (!event) { return false; }
  focusedItemVisible.value = keys.includes(event.positionKey);
}

function init() {
  requestId.value += 1;
  topic.value = null;
  loadedKey.value = null;
  loader.value = null;
  respondToRoute();
}

function routeTopicParams() {
  return route.path.startsWith('/p/') ? { poll_key: route.params.key } : { discussion_key: route.params.key };
}

function hasRouteKey() {
  return !!route.params.key;
}

function routeSequenceId() {
  return Object.keys(route.params).includes('sequence_id') ? parseInt(route.params.sequence_id) : null;
}

function hasSequenceId(sequenceId) {
  return Number.isInteger(sequenceId);
}

function routeCommentId() {
  return parseInt(route.query.comment_id || route.params.comment_id) || null;
}

function initialFetchParams() {
  const remoteTopicParams = routeTopicParams();
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

  if (Object.keys(route.query).includes('newest')) {
    return {
      ...remoteTopicParams,
      order_by: 'sequence_id',
      order_desc: 1,
      per: padding
    };
  }

  return {
    ...remoteTopicParams,
    unread_or_newest: 1,
    per: padding
  };
}

function topicFromResponse(data) {
  const id = (data.topics || [])[0]?.id || (data.events || [])[0]?.topic_id;
  return Records.topics.find(id);
}

function setupTopicFromResponse(data, id) {
  if (id !== requestId.value) { return; }

  const t = topicFromResponse(data);
  if (!t) { return; }

  if (t.group() && t.group().newHost) { window.location.host = t.group().newHost; }
  topic.value = t;
  loadedKey.value = route.params.key;
  loader.value = new ThreadLoader(t);

  loadContent(routeTopicParams());
  loader.value.fetchedRules = loader.value.rules.filter(rule => rule.remote).map(rule => JSON.stringify(rule.remote));
  loader.value.firstLoad = true;
  loader.value.updateCollection();

  EventBus.$emit('currentComponent', {
    focusHeading: false,
    page: 'discussionPage',
    topic: topic.value,
    group: topic.value.group(),
    title: topic.value.topicable().title
  });

  watchRecords({
    key: 'strand' + topic.value.id,
    collections: ['events'],
    query: () => {
      if (!loader.value) { return; }
      loader.value.updateCollection();
      nextTick(() => scrollToAnchorIfNew());
    }
  });

  snackbar.value = !!focusMode.value;
  setAnchorFromRoute();
  nextTick(() => scrollToAnchorIfPresent());
}

function fetchInitialContent() {
  if (!hasRouteKey()) { return; }

  const id = requestId.value;
  const params = initialFetchParams();

  return Records.events.fetch({ params }).then(data => {
    setupTopicFromResponse(data, id);
  }).catch(error => {
    if (error.status) {
      EventBus.$emit('pageError', error);
      if ((error.status === 403) && !Session.isSignedIn()) { EventBus.$emit('openAuthModal'); }
    } else {
      console.error(error);
    }
  });
}

function loadContent(remoteTopicParams = null) {
  if (!topic.value) { return fetchInitialContent(); }
  if (loadedKey.value !== route.params.key) { return; }
  remoteTopicParams ||= { topic_id: topic.value.id };

  focusMode.value     = null;
  focusSelector.value = null;
  anchorSelector.value = null;
  anchorOffset.value  = null;

  loader.value.addLoadMyStuffRule();

  if (topic.value.itemsCount <= 1) {
    loader.value.addLoadNewestRule(remoteTopicParams);
    return;
  }

  if (route.path.startsWith('/p/')) {
    const poll = Records.polls.findByKey(route.params.key);
    if (poll && !(topic.value.topicableType === 'Poll' && topic.value.topicableId === poll.id)) {
      const event = Records.events.find({ topicId: topic.value.id, eventableType: 'Poll', eventableId: poll.id, kind: 'poll_created' })[0];
      if (event) {
        loader.value.addLoadSequenceIdRule(event.sequenceId, remoteTopicParams);
        focusSelector.value = `.sequenceId-${event.sequenceId}`;
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

  if (Object.keys(route.query).includes('unread')) {
    loader.value.clearRules();
    loader.value.addLoadUnreadOrNewestRule(remoteTopicParams);
    focusMode.value = 'unread';
    return;
  }

  if (Object.keys(route.query).includes('newest')) {
    loader.value.clearRules();
    loader.value.addLoadNewestRule(remoteTopicParams);
    focusMode.value = 'newest';
    return;
  }

  loader.value.addLoadUnreadOrNewestRule(remoteTopicParams);
}

function respondToRoute() {
  const load = loadContent();
  if (load) { return load; }

  snackbar.value = !!focusMode.value;
  setAnchorFromRoute();

  scrollToAnchorIfPresent();
  loader.value.fetch();
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
  if (anchorSelector.value && document.querySelector(anchorSelector.value)) {
    ScrollService.scrollTo(anchorSelector.value, anchorOffset.value);
  }
}

function scrollToAnchorIfNew() {
  if (anchorSelector.value && lastAnchorSelector.value !== anchorSelector.value) {
    ScrollService.scrollTo(anchorSelector.value, anchorOffset.value);
    lastAnchorSelector.value = anchorSelector.value;
  }
}
</script>

<template lang="pug">
.strand-page
  v-main
    v-container.max-width-800.px-0.px-sm-3#strand-page(v-if="topic")
      discussion-fork-actions(v-if="topic" :topic='topic' :key="'fork-actions'+ topic.id")
      v-sheet.strand-card.thread-card.mb-8.pb-4.rounded(elevation=1)
        strand-list.pr-1.pr-sm-3.px-sm-2(:loader="loader" :collection="loader.collection" :focus-selector="focusSelector" :focus-mode="focusMode")
        strand-actions-panel(:topic="topic")
  strand-toc-nav(v-if="loader" :topic="topic" :loader="loader" :key="topic.id" :focus-mode="focusMode" :focus-selector="focusSelector" :focused-item-visible="focusedItemVisible")
  v-fab(v-if="!$vuetify.display.mdAndUp" icon app location="bottom right" @click="openThreadNav" color="primary" variant="tonal")
    v-icon(:icon="mdiMenuOpen" )
</template>
