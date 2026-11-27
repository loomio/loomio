<script setup lang="js">
import { ref, computed, watch, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter, useRoute } from 'vue-router';
import { useDisplay } from 'vuetify';
import { useTheme } from 'vuetify';
import { uniqBy } from 'lodash-es';
import { unreadCutoffDate } from '@/shared/helpers/unread_cutoff.mjs';

import AppConfig from '@/shared/services/app_config';
import Session from '@/shared/services/session';
import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import GroupAbility from '@/shared/abilities/group_ability';
import LmoUrlService from '@/shared/services/lmo_url_service';
import { sidebarOpen } from '@/shared/services/sidebar_state';
import { colorIsTransparent } from '@/shared/helpers/color.mjs';

import SidebarSubgroups from '@/components/sidebar/subgroups';
import SidebarActivityLinks from '@/components/sidebar/activity_links.vue';
import SidebarSettings from '@/components/sidebar/settings';
import SidebarHelp from '@/components/sidebar/help';
import { useCurrentUserGroups } from '@/composables/useCurrentUserGroups';
import { useBookmarks } from '@/composables/useBookmarks';
import { usePendingPolls } from '@/composables/usePendingPolls';

import { mdiCog } from '@mdi/js';

const { t } = useI18n();
const router = useRouter();
const route = useRoute();
const display = useDisplay();
const theme = useTheme();

const page = ref('dashboardPage');
const organization = ref(null);
const open = sidebarOpen;
const group = ref(null);
const showSettings = ref(false);

const { loadGroups } = useCurrentUserGroups();
const { loadBookmarks } = useBookmarks();
const { loadPendingPolls, findPendingPolls } = usePendingPolls();

// Computed properties
const greySidebarLogo = computed(() =>
  AppConfig.features.app.gray_sidebar_logo_in_dark_mode && theme.global.name.value.startsWith("dark")
);
const drawerColor = computed(() =>
  !display.mdAndUp.value && colorIsTransparent(theme.current.value.colors.drawer) ? 'surface' : 'drawer'
);
const activeGroup = computed(() => group.value ? [group.value.id] : []);
const activeGroupId = computed(() => group.value?.id || null);
const isDashboardRoute = computed(() => route.path === '/dashboard' || route.path.startsWith('/dashboard/'));
const logoUrl = computed(() => AppConfig.theme.app_logo_src);
const logoInline = computed(() => logoUrl.value === '/brand/logo-current-color.svg');
const logoSvg = ref('');
const showTemplateGallery = computed(() => AppConfig.features.app.template_gallery);

const user = computed(() => Session.user());
const isSignedIn = computed(() => Session.isSignedIn());
const canStartGroups = computed(() => GroupAbility.canCreate());

const organizations = computed(() => {
  const orphanOrganizations = Session.user().orphanSubgroups().map(subgroup => {
    const parent = subgroup.parent();
    return parent.isVisibleToPublic ? parent : subgroup;
  });
  return uniqBy(Session.user().parentGroups().concat(orphanOrganizations), 'id');
});

const openCounts = computed(() => {
  const counts = {};
  const recentCutoff = unreadCutoffDate();
  Session.user().groups().forEach(g => {
    counts[g.id] = g.topics().filter(topic => topic.isUnread() && topic.lastActivityAt > recentCutoff).length;
  });
  return counts;
});

const unreadTopicCounts = computed(() => {
  const counts = {};
  const recentCutoff = unreadCutoffDate();
  Records.topics.collection.chain().find({discardedAt: null, lastActivityAt: {$gt: recentCutoff}}).where(t => t.isUnread()).data().forEach((t) => {
    counts['total'] = (counts['total'] || 0) + 1;
    const groupId = t.groupId || 'direct'
    counts[groupId] = (counts[groupId] || 0) + 1;
  });
  return counts;
});

const votesNeededCounts = computed(() => {
  const counts = {};
  findPendingPolls().forEach(poll => {
    counts.total = (counts.total || 0) + 1;
    if (poll.groupId) {
      counts[poll.groupId] = (counts[poll.groupId] || 0) + 1;
    }
  });
  return counts;
});

function hasActivity(unread, votes) {
  return (unread || 0) > 0 || (votes || 0) > 0;
}

function mySubgroups(org) {
  return org.subgroups().filter(g => !g.isDiscarded() && g.membershipFor(Session.user()));
}

function isOrgExpanded(org) {
  return organizations.value.length === 1 || organization.value?.id === org.id;
}

function orgUnreadCount(org) {
  const own = openCounts.value[org.id] || 0;
  if (isOrgExpanded(org)) { return own; }
  return mySubgroups(org).reduce((sum, sub) => sum + (openCounts.value[sub.id] || 0), own);
}

function orgVotesCount(org) {
  const own = votesNeededCounts.value[org.id] || 0;
  if (isOrgExpanded(org)) { return own; }
  return mySubgroups(org).reduce((sum, sub) => sum + (votesNeededCounts.value[sub.id] || 0), own);
}

function orgHasSubgroupUnread(org) {
  return !isOrgExpanded(org) && mySubgroups(org).some(sub => (openCounts.value[sub.id] || 0) > 0);
}

function orgHasSubgroupVotes(org) {
  return !isOrgExpanded(org) && mySubgroups(org).some(sub => (votesNeededCounts.value[sub.id] || 0) > 0);
}

const bookmarksCount = computed(() => Records.bookmarks.find({userId: Session.userId, discardedAt: null}).length);

const CARRIED_THREAD_FILTERS = new Set(['locked', 'all']);
const carriedThreadQuery = computed(() => {
  const q = {};
  if (CARRIED_THREAD_FILTERS.has(route.query?.t)) { q.t = route.query.t; }
  return q;
});

const urlFor = (model, action, params) => {
  return LmoUrlService.route({model, action, params});
};

const groupLink = (target) => ({
  path: urlFor(target),
  query: carriedThreadQuery.value
});

const dashboardLink = computed(() => ({
  path: '/dashboard',
  query: carriedThreadQuery.value
}));

const openIfPinned = () => {
  open.value = !!isSignedIn.value &&
    display.lgAndUp.value &&
    (user.value.experiences['sidebar'] === undefined || user.value.experiences['sidebar'] === true);
};

// TopicItem listeners setup
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
      if (Session.user().groups().length === 0 && GroupAbility.canCreate()) {
        router.replace("/g/new");
      }
      if (Session.user().groups().length === 1) {
        router.replace(`/g/${Session.user().groups()[0].key}`);
      }
    }
  });
  Records.topics.fetch({ params: { unread: 1, last_activity_gte: unreadCutoffDate().toISOString() } })
  loadPendingPolls();
  loadBookmarks();
};

let hasFetched = false;
const fetchOnce = () => {
  if (hasFetched || !Session.isSignedIn()) return;
  hasFetched = true;
  fetchData();
};

EventBus.$on('signedIn', u => {
  openIfPinned();
});

onMounted(() => {
  openIfPinned();
  if (open.value) fetchOnce();
  if (logoInline.value) {
    fetch(logoUrl.value)
      .then(response => response.ok ? response.text() : '')
      .then(svg => { logoSvg.value = svg; })
      .catch(() => {});
  }
});

watch(open, (val) => {
  if (val) fetchOnce();
  EventBus.$emit("sidebarOpen", val);
});
</script>

<template lang="pug">
v-navigation-drawer.sidenav-left.lmo-no-print(app v-model="open" :color="drawerColor")
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
    v-list.sidebar__groups(nav density="compact" :lines="false")
      v-list-item.sidebar__list-item-button--recent(
        slim
        :to="dashboardLink"
        :active="isDashboardRoute"
        :lines="hasActivity(unreadTopicCounts['total'], votesNeededCounts.total) ? 'two' : false"
      )
        template(v-slot:prepend)
          v-avatar(:size="24" color="transparent")
            common-icon(name="mdi-account-group" :size="20")
        v-list-item-title {{ t('dashboard_cards.all_groups') }}
        sidebar-activity-links(
          :unread="unreadTopicCounts['total'] || 0"
          :votes="votesNeededCounts.total || 0"
          base-path="/dashboard"
        )

      template(v-for="org in organizations" :key="org.id")
        v-list-item.sidebar__group(
          slim
          :to="groupLink(org)"
          :active="activeGroupId === org.id"
          :lines="hasActivity(orgUnreadCount(org), orgVotesCount(org)) ? 'two' : false"
        )
          template(v-slot:prepend)
            group-avatar(:group="org" :size="24")
          v-list-item-title {{ org.name }}
          sidebar-activity-links(
            :unread="orgUnreadCount(org)"
            :votes="orgVotesCount(org)"
            :base-path="urlFor(org)"
            :include-subgroups-unread="orgHasSubgroupUnread(org)"
            :include-subgroups-votes="orgHasSubgroupVotes(org)"
          )
        sidebar-subgroups(
          v-if="isOrgExpanded(org)"
          :organization="org"
          :open-counts="openCounts"
          :votes-needed-counts="votesNeededCounts"
          :active-group-id="activeGroupId"
        )

      v-btn.sidebar-start-group.mt-2(
        block
        variant="tonal"
        color="primary"
        v-if="canStartGroups"
        to="/g/new"
      )
        span {{ t('sidebar.new_group') }}

    sidebar-help

  template(v-slot:append)
    v-divider
    v-layout.mx-13.my-3(column align-center style="max-height: 64px" :class="{greySidebarLogo: greySidebarLogo}")
      .sidebar__loomio-logo.text-accent(v-if="logoInline && logoSvg" v-html="logoSvg")
      v-img(v-else :src="logoUrl")

</template>
<style>
.sidenav-left .v-list {
  background: inherit;
}

.sidebar__loomio-logo {
  display: block;
  width: 100%;
  max-width: 100%;
  min-width: 0;
  overflow: hidden;
  line-height: 0;
}
.sidebar__loomio-logo svg {
  display: block;
  width: 100% !important;
  max-width: 100%;
  height: auto !important;
}

.greySidebarLogo {
  filter: saturate(99999%) grayscale(1);
}
</style>
