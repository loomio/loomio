<script setup lang="js">
import { ref, computed, watch, onMounted } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useDisplay } from 'vuetify';
import { useTheme } from 'vuetify';
import { compact } from 'lodash-es';
import { subWeeks } from 'date-fns';

import AppConfig from '@/shared/services/app_config';
import Session from '@/shared/services/session';
import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import LmoUrlService from '@/shared/services/lmo_url_service';

import SidebarSubgroups from '@/components/sidebar/subgroups';
import SidebarSettings from '@/components/sidebar/settings';
import SidebarHelp from '@/components/sidebar/help';
import { useWatchRecords } from '@/composables/useWatchRecords';
import { useCurrentUserGroups } from '@/composables/useCurrentUserGroups';

import { mdiCog } from '@mdi/js';

const router = useRouter();
const route = useRoute();
const display = useDisplay();
const theme = useTheme();

const user = ref(Session.user());
const page = ref('dashboardPage');
const organization = ref(null);
const open = ref(false);
const group = ref(null);
const organizations = ref([]);
const unreadTopicCounts = ref({});
const pollsToVoteOnCount = ref(0);
const openGroups = ref([]);
const openCounts = ref({});
const showSettings = ref(false);
const isSignedIn = ref(Session.isSignedIn());
const canStartGroups = ref(AbilityService.canStartGroups());

const { watchRecords } = useWatchRecords();
const { loadGroups } = useCurrentUserGroups();

// Computed properties
const greySidebarLogo = computed(() =>
  AppConfig.features.app.gray_sidebar_logo_in_dark_mode && theme.global.name.value.startsWith("dark")
);
const activeGroup = computed(() => group.value ? [group.value.id] : []);
const logoUrl = computed(() => AppConfig.theme.app_logo_src);
const showTemplateGallery = computed(() => AppConfig.features.app.template_gallery);
const showNewThreadButton = computed(() => AppConfig.features.app.new_thread_button);

const urlFor = (model, action, params) => {
  return LmoUrlService.route({model, action, params});
};

const updateSessionState = () => {
  user.value = Session.user();
  isSignedIn.value = Session.isSignedIn();
  canStartGroups.value = AbilityService.canStartGroups();
};

const openIfPinned = () => {
  open.value = !!isSignedIn.value &&
    display.lgAndUp.value &&
    (user.value.experiences['sidebar'] === undefined || user.value.experiences['sidebar'] === true);
};

// Event listeners setup
EventBus.$on('toggleSidebar', () => {
  open.value = !open.value;
  Records.users.saveExperience('sidebar', open.value);
});

EventBus.$on('currentComponent', data => {
  if (data.group) {
    page.value = 'groupPage';
    group.value = data.group;
    organization.value = data.group.parentOrSelf();
  } else {
    group.value = null;
    organization.value = null;
  }
});

const fetchData = () => {
  loadGroups().then(() => {
    if (route.path === "/dashboard") {
      if (Session.user().groups().length === 0 && AbilityService.canStartGroups()) {
        router.replace("/g/new");
      }
      if (Session.user().groups().length === 1) {
        router.replace(`/g/${Session.user().groups()[0].key}`);
      }
    }
  });
  Records.topics.fetch({ params: { unread: 1, exclude_types: 'reaction' } })
  Records.stances.fetch({ path: 'my_stances' })
};


const updateGroups = () => {
  organizations.value = compact(Session.user().parentGroups().concat(Session.user().orphanParents())) || [];
  openCounts.value = {};
  openGroups.value = [];
  Session.user().groups().forEach(g => {
    openCounts.value[g.id] = g.topics().filter(topic => topic.isUnread()).length;
  });
  Session.user().parentGroups().forEach(g => {
    if (organization.value && (organization.value.id === g.parentOrSelf().id)) {
      openGroups.value[g.id] = true;
    }
  });
};

const updateUnreadCounts = () => {
  unreadTopicCounts.value = {};
  const recentCutoff = subWeeks(new Date, 6);
  Records.topics.collection.chain().find({lastActivityAt: {$gt: recentCutoff}}).where(t => t.isUnread()).data().forEach((t) => {
    unreadTopicCounts.value['total'] = (unreadTopicCounts.value['total'] || 0) + 1;
    const groupId = t.groupId || 'direct'
    unreadTopicCounts.value[groupId] = (unreadTopicCounts.value[groupId] || 0) + 1;
  });
}

const updatePollsToVoteOnCount = () => {
  pollsToVoteOnCount.value = Records.polls.collection.chain()
    .find({discardedAt: null, closingAt: {$ne: null}, closedAt: null, myStanceId: {$ne: null}})
    .data()
    .filter(p => p.iCanVote() && !p.iHaveVoted()).length;
}

watchRecords({
  collections: ['users'],
  query: () => { updateSessionState() }
});

watchRecords({
  collections: ['memberships'],
  query: () => { updateGroups() }
});

watchRecords({
  collections: ['topics'],
  query: () => { updateUnreadCounts() }
});

watchRecords({
  collections: ['stances'],
  query: () => { updatePollsToVoteOnCount() }
});

let hasFetched = false;
const fetchOnce = () => {
  if (hasFetched || !Session.isSignedIn()) return;
  hasFetched = true;
  fetchData();
};

EventBus.$on('signedIn', u => {
  updateSessionState();
  openIfPinned();
});

onMounted(() => {
  updateSessionState();
  openIfPinned();
  if (open.value) fetchOnce();
});

watch(organization, () => { updateGroups() });
watch(open, (val) => {
  if (val) fetchOnce();
  EventBus.$emit("sidebarOpen", val);
});
</script>

<template lang="pug">
v-navigation-drawer.sidenav-left.lmo-no-print(app v-model="open")
  sidebar-settings(
    v-if="showSettings"
    @closeSettings="showSettings = false"
  )

  template(v-else)
    v-list(nav)
      v-list-item.sidebar__user-dropdown(nav slim @click.prevent="showSettings = true" :append-icon="mdiCog")
        template(v-slot:prepend)
          user-avatar.mr-2(:user="user" :size="32")
        v-list-item-title {{ user.name }}
        v-list-item-subtitle {{ user.email }}

    v-divider
    v-list(nav density="compact" :lines="false")
      v-list-item.sidebar__list-item-button--recent(to="/dashboard" :title="$t('dashboard_page.dashboard')")
      v-list-item(to="/dashboard/polls_to_vote_on")
        v-list-item-title(:class="{'text-medium-emphasis': pollsToVoteOnCount === 0}") {{ $t('dashboard_page.polls_to_vote_on_count', {count: pollsToVoteOnCount}) }}
      v-list-item(to="/inbox")
        v-list-item-title(:class="{'text-medium-emphasis': unreadTopicCounts['total'] === 0}")
          span(v-if="unreadTopicCounts['total']" v-t="{path: 'sidebar.unread_threads_count', args: {count: unreadTopicCounts['total']}}")
          span(v-else v-t="'sidebar.unread_threads'")
      v-list-item.sidebar__list-item-button--private(to="/dashboard/direct_discussions")
        v-list-item-title(:class="{'text-medium-emphasis': !unreadTopicCounts['direct']}")
          span(v-t="'sidebar.direct_threads'")
          template(v-if="unreadTopicCounts['direct']")
            | &nbsp;
            span ({{unreadTopicCounts['direct']}})
      v-list-item(to="/tasks" :disabled="organizations.length == 0" :title="$t('tasks.tasks')")

    v-divider
    v-list.sidebar__groups(nav density="comfortable")
      v-list-subheader
        span(v-t="'common.groups'")
      template(v-for="group in organizations" :key="group.id")
        v-list-item(:to="urlFor(group)")
          template(v-slot:prepend)
            group-avatar.mr-2(:group="group")
          v-list-item-title
            span {{group.name}}
            template(v-if='openCounts[group.id]')
              | &nbsp;
              span ({{openCounts[group.id]}})
        sidebar-subgroups(v-if="group == organization" :organization="group" :open-counts="openCounts")

      v-btn.sidebar-start-group(
        block
        variant="tonal"
        color="primary"
        v-if="canStartGroups"
        to="/g/new"
      )
        span(v-t="'sidebar.new_group'")

    v-divider

    sidebar-help

  template(v-slot:append)
    v-divider
    v-layout.mx-13.my-3(column align-center style="max-height: 64px" :class="{greySidebarLogo: greySidebarLogo}")
      v-img(:src="logoUrl")

</template>
<style lang="sass">
.greySidebarLogo
  filter: saturate(99999%) grayscale(1)
</style>
