<script setup lang="js">
import { ref, watch, onMounted, onUnmounted, nextTick } from 'vue';
import { useRoute } from 'vue-router';
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import EventBus from '@/shared/services/event_bus';
import ThreadLoader from '@/shared/loaders/thread_loader';
import StrandActionsPanel from './actions_panel';
import ScrollService from '@/shared/services/scroll_service';
import { mdiMenuOpen } from '@mdi/js';
import { useWatchRecords } from '@/shared/composables/use_watch_records';

const route = useRoute();
const { watchRecords } = useWatchRecords();

const discussion = ref(null);
const loader = ref(null);
const position = ref(0);
const group = ref(null);
const discussionFetchError = ref(null);
const focusMode = ref(null);
const focusSelector = ref(null);
const anchorSelector = ref(null);
const anchorOffset = ref(null);
const lastAnchorSelector = ref(null);
const snackbar = ref(false);

const openThreadNav = () => {
  EventBus.$emit('toggleThreadNav');
};

const scrollToAnchorIfPresent = () => {
  if (document.querySelector(anchorSelector.value)) {
    ScrollService.scrollTo(anchorSelector.value, anchorOffset.value);
  }
};

const scrollToAnchorIfNew = () => {
  if (lastAnchorSelector.value !== anchorSelector.value) {
    ScrollService.scrollTo(anchorSelector.value, anchorOffset.value);
    lastAnchorSelector.value = anchorSelector.value;
  }
};

const loadContent = () => {
  if (!discussion.value) { return; }
  if (discussion.value.key !== route.params.key) { return; }

  focusMode.value = null;
  focusSelector.value = null;
  anchorSelector.value = null;
  anchorOffset.value = null;

  loader.value.addContextRule();
  loader.value.addLoadMyStuffRule();

  if (discussion.value.itemsCount === 0) {
    loader.value.addLoadNewestRule();
    return;
  }

  if (Object.keys(route.params).includes('sequence_id')) {
    const sequenceId = parseInt(route.params.sequence_id);
    loader.value.addLoadSequenceIdRule(sequenceId);
    focusSelector.value = `.sequenceId-${sequenceId}`;
    return;
  }

  if (route.params.comment_id) {
    loader.value.addLoadCommentRule(parseInt(route.params.comment_id));
    loader.value.addLoadNewestRule();
    focusSelector.value = `#comment-${parseInt(route.params.comment_id)}`;
    return;
  }

  if (Object.keys(route.query).includes('unread')) {
    loader.value.clearRules();
    loader.value.addLoadUnreadRule();
    loader.value.addLoadNewestRule();
    focusMode.value = 'unread';
    anchorSelector.value = `.sequenceId-${parseInt(loader.value.firstUnreadSequenceId())}`;
    return;
  }

  if (Object.keys(route.query).includes('newest')) {
    loader.value.clearRules();
    loader.value.addLoadNewestRule();
    focusMode.value = 'newest';
    focusSelector.value = `.sequenceId-${parseInt(discussion.value.lastSequenceId())}`;
    return;
  }

  // never been read before
  if (!discussion.value.lastReadAt) {
    if (discussion.value.newestFirst) {
      loader.value.addLoadNewestRule();
    } else {
      loader.value.addLoadOldestRule();
    }
    anchorSelector.value = "#strand-page";
    return;
  }

  if (loader.value.firstUnreadSequenceId()) {
    loader.value.addLoadUnreadRule();
    loader.value.addLoadNewestRule();
    focusMode.value = 'unread';
    anchorSelector.value = `.sequenceId-${parseInt(loader.value.firstUnreadSequenceId())}`;
    return;
  } else {
    loader.value.addLoadNewestRule();
    focusMode.value = 'newest';
    anchorSelector.value = `.sequenceId-${parseInt(discussion.value.lastSequenceId())}`;
    return;
  }
};

const respondToRoute = () => {
  loadContent();
  snackbar.value = !!focusMode.value;

  if (route.query.current_action) {
    anchorSelector.value = '.actions-panel-end';
  } else {
    if (!anchorSelector.value) {
      anchorSelector.value = focusSelector.value;
      anchorOffset.value = null;
    }
  }

  scrollToAnchorIfPresent();

  loader.value.fetch();
};

const init = () => {
  Records.discussions.findOrFetchById(route.params.key, {exclude_types: 'poll outcome'}).then(disc => {
    if (disc.group().newHost) { window.location.host = disc.group().newHost; }
    discussion.value = disc;
    loader.value = new ThreadLoader(discussion.value);

    respondToRoute();

    EventBus.$emit('currentComponent', {
      focusHeading: false,
      page: 'discussionPage',
      discussion: discussion.value,
      group: discussion.value.group(),
      title: discussion.value.title
    });

    watchRecords({
      key: 'strand' + discussion.value.id,
      collections: ['events'],
      query: () => {
        loader.value.updateCollection();
        nextTick(() => scrollToAnchorIfNew());
      }
    });
  }).catch(function(error) {
    EventBus.$emit('pageError', error);
    if ((error.status === 403) && !Session.isSignedIn()) { EventBus.$emit('openAuthModal'); }
  });
};

const handleSetAnchor = (selector, offset) => {
  anchorSelector.value = selector;
  anchorOffset.value = offset;
};

onMounted(() => {
  EventBus.$on('setAnchor', handleSetAnchor);
  init();
});

onUnmounted(() => {
  EventBus.$off('setFocus');
  EventBus.$off('setAnchor', handleSetAnchor);
});

watch(() => route.params.key, init);
watch(() => route.params.sequence_id, respondToRoute);
watch(() => route.params.comment_id, respondToRoute);
watch(() => route.query.p, respondToRoute);
watch(() => route.query.k, respondToRoute);
watch(() => route.query.current_action, respondToRoute);
watch(() => route.query.unread, respondToRoute);
watch(() => route.query.newest, respondToRoute);
</script>

<template lang="pug">
.strand-page
  v-main
    v-container.max-width-800.px-0.px-sm-3#strand-page(v-if="discussion")
      thread-current-poll-banner(:discussion="discussion")
      discussion-fork-actions(:discussion='discussion' :key="'fork-actions'+ discussion.id")
      v-sheet.strand-card.thread-card.mb-8.pb-4.rounded(elevation=1)
        v-snackbar(v-if="focusMode" v-model="snackbar" location="bottom center" color="info")
          div.text-center
            span.text-center(v-if="focusMode == 'unread'" v-t="'strand_nav.showing_unread'")
            span.text-center(v-if="focusMode == 'newest'" v-t="'strand_nav.showing_latest'")
        strand-list.pt-3.pr-1.pr-sm-3.px-sm-2(:loader="loader" :collection="loader.collection" :focus-selector="focusSelector" :focus-mode="focusMode")
        strand-actions-panel(:discussion="discussion")
  strand-toc-nav(v-if="loader" :discussion="discussion" :loader="loader" :key="discussion.id" :focus-mode="focusMode" :focus-selector="focusSelector")
  v-fab(v-if="!$vuetify.display.mdAndUp" icon app location="bottom right" @click="openThreadNav" color="primary" variant="tonal")
    v-icon(:icon="mdiMenuOpen" )
</template>