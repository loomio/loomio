<script setup lang="js">
import EventBus      from '@/shared/services/event_bus';
import Records       from '@/shared/services/records';
import TopicService  from '@/shared/services/topic_service';
import LmoUrlService from '@/shared/services/lmo_url_service';
import ScrollService from '@/shared/services/scroll_service';
import Session       from '@/shared/services/session';
import PushSubscriptionService from '@/shared/services/push_subscription_service';
import { colorIsTransparent } from '@/shared/helpers/color.mjs';
import { notificationCatchUpTitleKey } from '@/shared/helpers/notification_volume_options';
import { useWatchRecords } from '@/composables/useWatchRecords';
import { ref, computed, onMounted, nextTick } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useDisplay, useTheme } from 'vuetify';
import { sortBy, last, pickBy } from 'lodash-es';
import { mdiArrowUpThin, mdiArrowDownThin, mdiCellphone, mdiEmailOutline, mdiLightningBolt, mdiMessageBadgeOutline } from '@mdi/js';

const volumeDisplayByState = {
  email_and_device_all_activity: { email: true,  device: true,  labelKey: 'change_volume_form.all_activity_option', summaryKey: 'change_volume_form.all_activity_option' },
  email_all_activity:            { email: true,  device: false, labelKey: 'change_volume_form.all_activity_option', summaryKey: 'change_volume_form.all_activity_option' },
  device_all_activity:           { email: false, device: true,  labelKey: 'change_volume_form.all_activity_option', summaryKey: 'change_volume_form.all_activity_option' },
  email_and_device:              { email: true,  device: true,  labelKey: 'change_volume_form.when_notified_option', summaryKey: 'strand_nav.email_and_device_when_notified' },
  email:                         { email: true,  device: false, labelKey: 'change_volume_form.when_notified_option', summaryKey: 'strand_nav.email_when_notified' },
  device:                        { email: false, device: true,  labelKey: 'change_volume_form.when_notified_option', summaryKey: 'strand_nav.device_notification_when_notified' },
  catch_up:                      { email: true,  device: false, labelKey: 'strand_nav.daily_catch_up_email', summaryKey: 'strand_nav.daily_catch_up_email' },
  none:                          { email: false, device: false, labelKey: 'strand_nav.no_notifications', summaryKey: 'strand_nav.no_notifications' },
};

const props = defineProps({
  topic:             Object,
  loader:            Object,
});

const route = useRoute();
const router = useRouter();
const display = useDisplay();
const theme = useTheme();
const { watchRecords } = useWatchRecords();

const open        = ref(null);
const deviceNotificationsAvailable = ref(false);
const pinnedItems = ref([]);
const baseUrl     = ref('');
const topicActions = ref({});

const selectedSequenceId = computed(() => parseInt(route.params.sequence_id));
const selectedCommentId  = computed(() => parseInt(route.params.comment_id));
const isSignedIn         = computed(() => Session.isSignedIn());
const drawerColor        = computed(() =>
  !display.mdAndUp.value && colorIsTransparent(theme.current.value.colors['thread-drawer']) ? 'background' : 'thread-drawer'
);
const memberActions      = computed(() => Object.entries(pickBy(topicActions.value, a => a.name && a.collection === 'members' && a.canPerform())).map(([key, action]) => ({ key, action })));
const menuActions        = computed(() => {
  return Object.entries(pickBy(topicActions.value, a => a.name && a.collection === 'actions' && a.canPerform())).map(([key, action]) => ({ key, action }));
});
const volumeDisplay = computed(() => {
  const emailCatchUpDay = Session.user().emailCatchUpDay;
  const state = props.topic.notificationVolumeState(
    emailCatchUpDay != null,
    deviceNotificationsAvailable.value
  );
  if (state !== 'catch_up') return volumeDisplayByState[state];

  const labelKey = notificationCatchUpTitleKey(emailCatchUpDay);
  return { ...volumeDisplayByState[state], labelKey, summaryKey: labelKey };
});

function scrollToEnd() {
  props.loader.addLoadArgsRule({ order_by: 'position_key', order_desc: true });
  props.loader.fetch().then(() => {
    props.loader.updateCollection();
    const endEvent = Records.topicItems.collection.chain()
      .find({ topicId: props.topic.id })
      .simplesort('positionKey', true)
      .limit(1)
      .data()[0];
    if (endEvent) nextTick(() => ScrollService.scrollTo(`.positionKey-${endEvent.positionKey}`));
  });
}

function scrollToLatest() {
  props.loader.addLoadNewestRule();
  props.loader.fetch().then(() => {
    props.loader.updateCollection();
    nextTick(() => ScrollService.scrollTo(`.sequenceId-${props.loader.lastSequenceId()}`));
  });
}

function scrollToNewToYou() {
  props.loader.addLoadUnreadRule();
  props.loader.fetch().then(() => {
    props.loader.updateCollection();
    nextTick(() => ScrollService.scrollTo(`.sequenceId-${props.loader.firstUnreadSequenceId()}`));
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
  PushSubscriptionService.subscriptions()
    .then(subscriptions => { deviceNotificationsAvailable.value = subscriptions.length > 0; })
    .catch(() => {});

  topicActions.value = TopicService.actions(props.topic);
  props.topic.fetchUsersNotifiedCount();
  baseUrl.value = LmoUrlService.route({ model: props.topic.topicable() });
  EventBus.$on('toggleTopicNav', () => { open.value = !open.value; });

  Records.topicItems.fetch({
    params: {
      exclude_types: 'topic',
      topic_id: props.topic.id,
      pinned: true,
      per: 200
    }
  });

  watchRecords({
    key: 'topic-nav' + props.topic.id,
    collections: ['topic_items', 'discussions', 'polls', 'topics', 'memberships'],
    query: () => {
      topicActions.value = TopicService.actions(props.topic);
      pinnedItems.value = Records.topicItems.collection.chain()
        .find({ topicId: props.topic.id, pinned: true })
        .simplesort('positionKey')
        .data()
        .filter(e => !e.model()?.discardedAt)
        .map(topic_item => {
          const model = topic_item.model();
          const isPoll = topic_item.kind === 'poll_created';
          const poll = isPoll ? model.poll() : null;
          return {
            key: topic_item.positionKey,
            sequenceId: topic_item.sequenceId,
            title: (model && model.title) || topic_item.pinnedTitle || topic_item.fillPinnedTitle(),
            poll,
            user: !isPoll && topic_item.actor() || null
          };
        });
    }
  });
});
</script>

<template lang="pug">
v-navigation-drawer.lmo-no-print.disable-select.topic-sidebar(v-if="topic" v-model="open" :permanent="$vuetify.display.mdAndUp" app fixed location="right" clipped :color="drawerColor" floating)
  v-list(nav slim density="compact" :lines="false")
    v-list-subheader(v-t="'strand_nav.jump_to'")
    v-list-item(color="info" value="toc-start" :prepend-icon="mdiArrowUpThin" :title="$t('strand_nav.start')" @click="scrollToTop" :to="baseUrl+'/0'")
    v-list-item(color="info" value="toc-new-to-you" :prepend-icon="mdiMessageBadgeOutline" :title="$t('strand_nav.new_to_you')" @click="scrollToNewToYou" v-if="loader.firstUnreadSequenceId()")
    v-list-item(color="info" value="toc-latest" :prepend-icon="mdiLightningBolt" :title="$t('strand_nav.latest')" @click="scrollToLatest" v-if="loader.lastSequenceId() !== topic.lastSequenceId()")
    v-list-item(v-for="item in pinnedItems" :key="item.key" :value="'toc-pinned-' + item.key" :title="item.title" :to="baseUrl+'/'+item.sequenceId" @click="scrollToSequenceId(item.sequenceId)")
      template(v-slot:prepend)
        poll-common-icon-panel(v-if="item.poll && item.poll.showResults()" :poll="item.poll" show-my-stance :size="24" :stanceSize="12")
        v-icon(v-else-if="item.user")
          user-avatar(:user="item.user" :size="24" no-link)
        v-icon(v-else) mdi-pin-outline
    v-list-item(color="info" value="toc-end" :prepend-icon="mdiArrowDownThin" :title="$t('strand_nav.end')" @click="scrollToEnd")
  template(v-if="isSignedIn")

    v-list(nav slim density="compact" :lines="false")
      v-list-subheader(v-t="'strand_nav.notifications'")
      v-list-item.topic-sidebar__notification-settings(:aria-label="$t(volumeDisplay.summaryKey)" @click="openVolumeForm")
        template(v-slot:prepend)
          v-icon.topic-sidebar__notification-email-icon.text-medium-emphasis(v-if="volumeDisplay.email" :icon="mdiEmailOutline" aria-hidden="true")
          v-icon.topic-sidebar__notification-device-icon.text-medium-emphasis(v-if="volumeDisplay.device" :icon="mdiCellphone" aria-hidden="true")
        v-list-item-title {{ $t(volumeDisplay.labelKey) }}

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

<style>
.topic-sidebar .v-list {
  background: inherit;
}

.topic-sidebar .v-list-item-title {
  white-space: normal !important;
}

.topic-sidebar .topic-sidebar__notification-settings .v-list-item-title {
  white-space: nowrap !important;
}

.topic-nav__stance-icon-container {
  display: inline-block;
}

.topic-nav__toc {
  display: flex;
  flex-direction: column;
  min-height: 70%;
}

.topic-nav__entry:empty {
  flex-grow: 1;
}

.topic-nav__entry {
  display: block;
  border-left: 2px solid #ccc;
  padding-left: 8px;
  padding-right: 8px;
  margin-left: 8px;
  min-height: 2px;
}

.topic-nav__entry--selected {
  border-color: rgb(var(--v-theme-primary)) !important;
}

.topic-nav__entry:hover {
  border-color: rgb(var(--v-theme-primary)) !important;
}

.topic-nav__entry:hover, .topic-nav__entry--visible {
  background-color: #f8f8f8;
}

.v-theme--dark .topic-nav__entry {
  border-left: 2px solid #999;
}
.v-theme--dark .topic-nav__entry:hover, .v-theme--dark .topic-nav__entry--visible {
  background-color: rgb(var(--v-theme-surface));
}
</style>
