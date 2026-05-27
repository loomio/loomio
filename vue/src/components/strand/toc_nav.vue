<script setup lang="js">
import EventBus      from '@/shared/services/event_bus';
import Records       from '@/shared/services/records';
import TopicService  from '@/shared/services/topic_service';
import LmoUrlService from '@/shared/services/lmo_url_service';
import ScrollService from '@/shared/services/scroll_service';
import Session       from '@/shared/services/session';
import { useWatchRecords } from '@/composables/useWatchRecords';
import { ref, computed, onMounted, nextTick } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { sortBy, last, pickBy } from 'lodash-es';
import { mdiArrowUpThin, mdiArrowDownThin, mdiBellOutline, mdiBellOffOutline, mdiBellRingOutline } from '@mdi/js';

const props = defineProps({
  topic:             Object,
  loader:            Object,
});

const route = useRoute();
const router = useRouter();
const { watchRecords } = useWatchRecords();

const open        = ref(null);
const pinnedItems = ref([]);
const baseUrl     = ref('');
const topicActions = ref({});

const selectedSequenceId = computed(() => parseInt(route.params.sequence_id));
const selectedCommentId  = computed(() => parseInt(route.params.comment_id));
const isSignedIn         = computed(() => Session.isSignedIn());
const memberActions      = computed(() => Object.entries(pickBy(topicActions.value, a => a.name && a.collection === 'members' && a.canPerform())).map(([key, action]) => ({ key, action })));
const menuActions        = computed(() => {
  return Object.entries(pickBy(topicActions.value, a => a.name && a.collection === 'actions' && a.canPerform())).map(([key, action]) => ({ key, action }));
});

function scrollToEnd() {
  props.loader.addLoadArgsRule({ order_by: 'position_key', order_desc: true });
  props.loader.fetch().then(() => {
    const endEvent = Records.events.collection.chain()
      .find({ topicId: props.topic.id })
      .simplesort('positionKey', true)
      .limit(1)
      .data()[0];
    if (endEvent) nextTick(() => ScrollService.scrollTo(`.positionKey-${endEvent.positionKey}`));
  });
}

function openVolumeForm() {
  EventBus.$emit('openModal', {
    component: 'ChangeVolumeForm',
    props: { model: props.topic }
  });
}


function scrollToTop() {
  ScrollService.scrollTo('.sequenceId-0');
}

function scrollToSequenceId(id) {
  ScrollService.scrollTo(`.sequenceId-${id}`);
}

onMounted(() => {
  topicActions.value = TopicService.actions(props.topic);
  props.topic.fetchUsersNotifiedCount();
  baseUrl.value = LmoUrlService.route({ model: props.topic.topicable() });
  EventBus.$on('toggleThreadNav', () => { open.value = !open.value; });

  Records.events.fetch({
    params: {
      exclude_types: 'topic',
      topic_id: props.topic.id,
      pinned: true,
      per: 200
    }
  });

  watchRecords({
    key: 'thread-nav' + props.topic.id,
    collections: ['events', 'discussions', 'polls', 'topics', 'memberships'],
    query: () => {
      topicActions.value = TopicService.actions(props.topic);
      pinnedItems.value = Records.events.collection.chain()
        .find({ topicId: props.topic.id, pinned: true })
        .simplesort('positionKey')
        .data()
        .filter(e => !e.model()?.discardedAt)
        .map(event => {
          const model = event.model();
          const isPoll = event.kind === 'poll_created';
          const poll = isPoll ? model.poll() : null;
          return {
            key: event.positionKey,
            sequenceId: event.sequenceId,
            title: (model && model.title) || event.pinnedTitle || event.fillPinnedTitle(),
            poll,
            user: !isPoll && event.actor() || null
          };
        });
    }
  });
});
</script>

<template lang="pug">
v-navigation-drawer.lmo-no-print.disable-select.thread-sidebar(v-if="topic" v-model="open" :permanent="$vuetify.display.mdAndUp"  app fixed location="right" clipped color="background" floating)
  v-list(nav slim density="compact" :lines="false")
    v-list-subheader(v-t="'strand_nav.jump_to'")
    v-list-item(color="info" value="toc-start" :prepend-icon="mdiArrowUpThin" :title="$t('strand_nav.start')" @click="scrollToTop" :to="baseUrl+'/0'")
    v-list-item(v-for="item in pinnedItems" :key="item.key" :value="'toc-pinned-' + item.key" :title="item.title" :to="baseUrl+'/'+item.sequenceId" @click="scrollToSequenceId(item.sequenceId)")
      template(v-slot:prepend)
        poll-common-icon-panel(v-if="item.poll && item.poll.showResults()" :poll="item.poll" show-my-stance :size="24" :stanceSize="12")
        v-icon(v-else-if="item.user")
          user-avatar(:user="item.user" :size="24" no-link)
        v-icon(v-else) mdi-pin-outline
    v-list-item(color="info" value="toc-end" :prepend-icon="mdiArrowDownThin" :title="$t('strand_nav.end')" @click="scrollToEnd" :to="baseUrl+'/'+topic.lastSequenceId()")
  template(v-if="isSignedIn")

    v-list(nav slim density="compact" :lines="false")
      v-list-subheader(v-t="'strand_nav.notifications'")
      v-list-item(:prepend-icon="topic.readerVolume === 'loud' ? mdiBellRingOutline : topic.readerVolume === 'quiet' ? mdiBellOffOutline : mdiBellOutline" :title="$t(topic.readerVolume === 'loud' ? 'strand_nav.email_all_activity' : topic.readerVolume === 'quiet' ? 'strand_nav.email_none' : 'strand_nav.email_notifications')" @click="openVolumeForm")

    v-list(nav slim density="compact" :lines="false" v-if="memberActions.length")
      v-list-subheader(v-t="'membership_card.thread_members'")
      v-list-item(
        v-for="{ key, action } in memberActions"
        :key="key"
        :class="`action-dock__button--${key}`"
        :title="$t(action.name, (action.nameArgs && action.nameArgs()) || {})"
        @click="action.perform()")
        template(v-slot:prepend)
          common-icon(:name="action.icon")

    v-list(nav slim density="compact" :lines="false" v-if="menuActions.length")
      v-list-subheader(v-t="'members_panel.header_actions'")
      v-list-item(
        v-for="{ key, action } in menuActions"
        :key="key"
        :class="`action-dock__button--${key}`"
        :title="$t(action.name, (action.nameArgs && action.nameArgs()) || {})"
        :to="action.to && action.to()"
        @click="action.perform && action.perform()")
        template(v-slot:prepend)
          common-icon(:name="action.icon")
</template>

<style lang="sass">
.thread-sidebar .v-list-item-title
  white-space: normal !important


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
