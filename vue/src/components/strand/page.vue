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

const route = useRoute();
const { watchRecords } = useWatchRecords();

const topic            = ref(null);
const loadedKey        = ref(null);
const loader           = ref(null);
const focusSelector    = ref(null);
const anchorSelector   = ref(null);
const anchorOffset     = ref(null);
const lastAnchorSelector = ref(null);
const focusedItemVisible = ref(false);
let cancelSettledAnchorScroll = null;

onMounted(() => {
  EventBus.$on('setAnchor', onSetAnchor);
  EventBus.$on('visibleKeys', onVisibleKeys);

  init();
});

onUnmounted(() => {
  EventBus.$off('setAnchor', onSetAnchor);
  EventBus.$off('visibleKeys', onVisibleKeys);
  cancelSettledScroll();
});

watch(() => route.params.key, init);
watch(() => route.params.sequence_id, respondToRoute);
watch(() => route.params.comment_id, respondToRoute);
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
  if (!focusSelector.value || !loader.value) { return true; }

  const match = focusSelector.value.match(/\.sequenceId-(\d+)/);
  if (!match) { return true; }

  const sequenceId = parseInt(match[1]);
  const event = Records.events.find({ topicId: topic.value.id, sequenceId })[0];
  if (!event) { return false; }
  focusedItemVisible.value = keys.includes(event.positionKey);
}

function init() {
  cancelSettledScroll();
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

// Thread loading strategy:
// 1. If a specific focus is given (a poll key for a non-topical poll, a sequence_id, or a comment_id),
//    load events around that item and scroll to it.
// 2. Otherwise, load unread-or-newest events, then scroll to:
//    a. The first unread item (if the user has read before and there is unread), or
//    b. The last item by position_key (if everything is read), or
//    c. The top (if nothing has been read yet — first visit).

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

  return {
    ...remoteTopicParams,
    unread_or_newest: 1,
    per: padding
  };
}

function fetchInitialContent() {
  if (!hasRouteKey()) { return; }

  const key = route.params.key;
  const params = initialFetchParams();

  return Records.events.fetch({ params }).then(data => {
    if (route.params.key !== key) { return; }

    const topicId = (data.topics || [])[0]?.id || (data.events || [])[0]?.topic_id;
    const t = Records.topics.find(topicId);
    if (!t) { return; }

    if (t.group() && t.group().newHost) { window.location.host = t.group().newHost; }
    topic.value = t;
    loadedKey.value = route.params.key;
    loader.value = new ThreadLoader(t);

    loadContent(routeTopicParams());
    loader.value.fetchedRules = loader.value.rules.filter(rule => rule.remote).map(rule => JSON.stringify(rule.remote));
    loader.value.isFirstLoad = false;
    loader.value.updateCollection();
    setAnchorFromRoute();

    EventBus.$emit('currentComponent', {
      focusHeading: false,
      page: 'discussionPage',
      topic: topic.value,
      group: topic.value.group(),
      title: topic.value.topicable().title
    });

    let scrolledToUnread = false;
    watchRecords({
      key: 'strand' + topic.value.id,
      collections: ['events'],
      query: () => {
        if (!loader.value) { return; }
        loader.value.updateCollection();
        if (!scrolledToUnread && !anchorSelector.value && !focusSelector.value && loader.value.lastReadAt) {
          const firstUnread = loader.value.firstUnreadSequenceId();
          if (firstUnread) {
            anchorSelector.value = `.sequenceId-${firstUnread}`;
          } else {
            const lastEvent = Records.events.collection.chain()
              .find({ topicId: topic.value.id })
              .simplesort('positionKey', true)
              .limit(1)
              .data()[0];
            if (lastEvent) anchorSelector.value = `.positionKey-${lastEvent.positionKey}`;
          }
          scrolledToUnread = true;
        }
        nextTick(() => scrollToAnchorIfNew());
      }
    });

    nextTick(() => scrollToAnchorIfPresent());
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

  loader.value.addLoadUnreadOrNewestRule(remoteTopicParams);
}

function respondToRoute() {
  const load = loadContent();
  if (load) { return load; }

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
  if (!anchorSelector.value) { return; }

  if (shouldSettleAnchorScroll()) {
    cancelSettledScroll();
    cancelSettledAnchorScroll = ScrollService.scrollToSettled(anchorSelector.value, anchorOffset.value);
  } else if (document.querySelector(anchorSelector.value)) {
    ScrollService.scrollTo(anchorSelector.value, anchorOffset.value);
  }
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
.strand-page
  v-main
    v-container.max-width-800.px-0.px-sm-3#strand-page(v-if="topic")
      discussion-fork-actions(v-if="topic" :topic='topic' :key="'fork-actions'+ topic.id")
      v-sheet.strand-card.thread-card.mb-8.pb-4.rounded(elevation=1)
        strand-list.pr-1.pr-sm-3.px-sm-2(:loader="loader" :collection="loader.collection" :focus-selector="focusSelector")
        strand-actions-panel(:topic="topic")
  strand-toc-nav(v-if="loader" :topic="topic" :loader="loader" :key="topic.id")
</template>
