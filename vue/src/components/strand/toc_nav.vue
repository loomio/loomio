<script setup lang="js">
import { ref, computed, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import EventBus from '@/shared/services/event_bus';
import Records from '@/shared/services/records';
import { sortBy, last } from 'lodash-es';
import ScrollService from '@/shared/services/scroll_service';
import Session from '@/shared/services/session';
import { mdiLightningBolt, mdiMessageBadgeOutline, mdiArrowUpThin, mdiArrowDownThin, mdiCog, mdiPlus } from '@mdi/js';
import { useWatchRecords } from '@/shared/composables/use_watch_records';
import { useUrlFor } from '@/shared/composables/use_url_for';

const props = defineProps({
  discussion: Object,
  loader: Object,
  focusMode: String,
  focusSelector: String
});

const route = useRoute();
const { watchRecords } = useWatchRecords();
const { urlFor } = useUrlFor();

const open = ref(null);
const items = ref([]);
const visibleKeys = ref([]);
const baseUrl = ref('');
let bootData = [];

const selectedSequenceId = computed(() => parseInt(route.params.sequence_id));
const selectedCommentId = computed(() => parseInt(route.params.comment_id));
const isSignedIn = computed(() => Session.isSignedIn());

const lastItemSequenceId = () => {
  return items.value[items.value.length - 1].sequenceId;
};

const scrollToNewest = () => {
  ScrollService.scrollTo(`.sequenceId-${props.discussion.lastSequenceId()}`);
};

const scrollToUnread = () => {
  ScrollService.scrollTo(`.sequenceId-${props.loader.firstUnreadSequenceId()}`);
};

const scrollToTop = () => {
  ScrollService.scrollTo('#strand-page');
};

const scrollToBottom = () => {
  ScrollService.scrollTo(`.positionKey-${last(items.value).key}`);
};

const scrollToSequenceId = (id) => {
  ScrollService.scrollTo(`.sequenceId-${id}`);
};

const buildItems = (bootDataParam) => {
  const itemsHash = {};

  baseUrl.value = urlFor(props.discussion);
  
  bootDataParam.forEach(row => {
    // row indexes
    // 0 positionKey,
    // 1 sequenceId,
    // 2 createdAt,
    // 3 userId,
    // 4 depth,
    // 5 descendantCount
    return itemsHash[row[0]] = {
      key: row[0],
      title: null,
      headings: [],
      sequenceId: row[1],
      createdAt: row[2],
      actorId: row[3],
      visible: false,
      depth: row[4],
      descendantCount: row[5],
      unread: props.loader.sequenceIdIsUnread(row[1]),
      poll: null,
      stance: null,
      visible: visibleKeys.value.includes(row[0])
    };
  });

  Records.events.collection.chain()
         .find({discussionId: props.discussion.id})
         .simplesort('positionKey')
         .data().forEach(event => {
    let poll;
    if (event.kind === "poll_created") {
      poll = event.model().poll();
      if (poll.discardedAt) { return; }
    }

    itemsHash[event.positionKey] = {
      key: event.positionKey,
      commentId: event.eventableType === 'Comment' ? event.eventableId : null,
      sequenceId: event.sequenceId,
      createdAt: event.createdAt,
      actorId: event.actorId,
      title: event.pinned ? (event.pinnedTitle || event.fillPinnedTitle()) : null,
      visible: false,
      unread: props.loader.sequenceIdIsUnread(event.sequenceId),
      headings: [],
      depth: event.depth,
      descendantCount: event.descendantCount,
      visible: visibleKeys.value.includes(event.positionKey),
      poll,
      stance: (poll && poll.myStance()) || null
    };
  });

  items.value = sortBy(Object.values(itemsHash), i => i.key);

  const createdEvent = props.discussion.createdEvent();
  items.value.unshift({
    key: createdEvent.positionKey,
    title: props.discussion.title,
    headings: [],
    sequenceId: 0,
    visible: visibleKeys.value.includes(createdEvent.positionKey),
    unread: false,
    event: createdEvent,
    poll: null,
    stance: null,
    depth: 1,
    descendantCount: 0
  });
};

const handleToggleThreadNav = () => {
  open.value = !open.value;
};

const handleVisibleKeys = (keys) => {
  visibleKeys.value = keys;
  items.value.forEach(item => {
    item.visible = visibleKeys.value.includes(item.key);
  });
};

onMounted(() => {
  EventBus.$on('toggleThreadNav', handleToggleThreadNav);

  Records.events.fetch({
    params: {
      exclude_types: 'group discussion',
      discussion_id: props.discussion.id,
      pinned: true,
      per: 200
    }
  });

  Records.events.remote.fetch({
    path: 'timeline',
    params: {
      discussion_id: props.discussion.id
  }}).then(data => {
    bootData = data;
    return buildItems(bootData);
  });

  watchRecords({
    key: 'thread-nav' + props.discussion.id,
    collections: ["events", "discussions"],
    query: () => {
      if (bootData.length) { buildItems(bootData); }
    }
  });

  EventBus.$on('visibleKeys', handleVisibleKeys);
});
</script>

<template lang="pug">
v-navigation-drawer.lmo-no-print.disable-select.thread-sidebar(v-if="discussion" v-model="open" :permanent="$vuetify.display.mdAndUp"  app fixed location="right" clipped color="background" floating)
  template(v-if="items.length > 1")
    v-list(nav density="compact" :lines="false")
      v-list-subheader(v-t="'strand_nav.jump_to'")
      v-list-item(color="info" :prepend-icon="mdiArrowUpThin" :title="$t('strand_nav.start')" @click="scrollToTop" :to="baseUrl+'/0'")
      v-list-item(color="info" :active="focusMode == 'unread'" :prepend-icon="mdiMessageBadgeOutline" :title="$t('strand_nav.unread')" @click="scrollToUnread" :to="baseUrl+'?unread'" v-if="loader.firstUnreadSequenceId()" exact)
      v-list-item(color="info" :active="focusMode == 'newest'" :prepend-icon="mdiLightningBolt" :title="$t('strand_nav.latest')" @click="scrollToNewest" :to="baseUrl+'?newest'" exact)
      //v-list-item(:prepend-icon="mdiPlus" :title="$t('strand_nav.add_comment')" @click="scrollToNewest" :to="baseUrl+'?newest'" exact)
      //v-list-item(:prepend-icon="mdiArrowDownThin" :title="$t('strand_nav.bottom')" @click="scrollToSequenceId(lastItemSequenceId())" :to="baseUrl+'/'+lastItemSequenceId()" exact)
      v-list-subheader(v-t="'strand_nav.timeline'")
    div.strand-nav__toc
      router-link.strand-nav__entry.text-caption(
        :class="{'strand-nav__entry--visible': item.visible, 'strand-nav__entry--selected': (item.sequenceId == selectedSequenceId || item.commentId == selectedCommentId), 'strand-nav__entry--unread': isSignedIn && item.unread}"
        :style="{'border-width': (item.depth * 2)+'px'}"
        v-for="item in items"
        :key="item.key"
        :to="baseUrl+'/'+item.sequenceId"
        @click="scrollToSequenceId(item.sequenceId)")
          .strand-nav__stance-icon-container(v-if="item.poll && item.poll.showResults()")
            poll-common-icon-panel.poll-proposal-chart-panel__chart.mr-1(:poll="item.poll" show-my-stance :size="18" :stanceSize="12")
          //span {{item.key}}
          span(v-if="item.title") {{item.title}}
</template>

<style lang="sass">
.strand-nav__stance-icon-container
  display: inline-block

.strand-nav__toc
  display: flex
  flex-direction: column
  min-height: 70%

.strand-nav__entry:empty
  flex-grow: 1

.strand-nav__entry
  display: block
  border-left: 2px solid #ccc
  padding-left: 8px
  padding-right: 8px
  margin-left: 8px
  min-height: 2px

.strand-nav__entry--unread
  border-color: var(--v-accent-lighten1)!important

.strand-nav__entry--selected
  border-color: var(--v-primary-darken1)!important
// .strand-nav__entry--visible
//   border-color: var(--v-primary-darken1)!important

.strand-nav__entry:hover
  border-color: var(--v-primary-darken1)!important

.strand-nav__entry:hover, .strand-nav__entry--visible
  background-color: #f8f8f8

.v-theme--dark, .v-theme--darkBlue
  .strand-nav__entry
    border-left: 2px solid #999
  .strand-nav__entry:hover, .strand-nav__entry--visible
    background-color: #222


</style>