<script setup lang="js">
import { ref, computed, watch, onMounted, onUnmounted } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useDisplay } from 'vuetify';
import { useTheme } from 'vuetify';
import { compact, filter } from 'lodash-es';
import { subDays } from 'date-fns';

import AppConfig from '@/shared/services/app_config';
import Session from '@/shared/services/session';
import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import InboxService from '@/shared/services/inbox_service';
import LmoUrlService from '@/shared/services/lmo_url_service';

import SidebarSubgroups from '@/components/sidebar/subgroups';
import SidebarSettings from '@/components/sidebar/settings';
import SidebarHelp from '@/components/sidebar/help';

import { mdiPlus, mdiCog } from '@mdi/js';

const router = useRouter();
const route = useRoute();
const display = useDisplay();
const theme = useTheme();

const user = ref(Session.user());
const page = ref('dashboardPage');
const organization = ref(null);
const discussions = ref([]);
const discussionsGroup = ref(null);
const open = ref(false);
const group = ref(null);
const version = ref(AppConfig.version);
const tree = ref([]);
const myGroups = ref([]);
const otherGroups = ref([]);
const organizations = ref([]);
const unreadCounts = ref({});
const openGroups = ref([]);
const openCounts = ref({});
const unreadDirectThreadsCount = ref(0);
const showSettings = ref(false);
const watchedRecords = ref([]);

// Computed properties
const canStartGroups = computed(() => AbilityService.canStartGroups());
const greySidebarLogo = computed(() => 
  AppConfig.features.app.gray_sidebar_logo_in_dark_mode && theme.global.name.value.startsWith("dark")
);
const isSignedIn = computed(() => Session.isSignedIn());
const activeGroup = computed(() => group.value ? [group.value.id] : []);
const logoUrl = computed(() => AppConfig.theme.app_logo_src);
const showTemplateGallery = computed(() => AppConfig.features.app.template_gallery);
const showNewThreadButton = computed(() => AppConfig.features.app.new_thread_button);

// Methods
const unreadThreadCount = () => {
  return InboxService.unreadCount();
};

const pollsToVoteOnCount = () => {
  const groupIds = Session.user().groupIds();
  const pollIds = Records.stances.find({myStance: true}).map(stance => stance.pollId);

  let chain = Records.polls.collection.chain();
  chain = chain.find({discardedAt: null, closingAt: {$ne: null}});
  chain = chain.find({$or: [{groupId: {$in: groupIds}}, {id: {$in: pollIds}}, {authorId: Session.user().id}]});
  chain = chain.find({$or: [{closedAt: null}, {closedAt: {$gt: subDays(new Date, 3)}}]});

  const votable = p => p.iCanVote() && !p.iHaveVoted();
  const votePolls = filter(chain.data(), votable);
  
  return votePolls.length;
};

const urlFor = (model, action, params) => {
  return LmoUrlService.route({model, action, params});
};

const watchRecordsFunc = (options) => {
  const { collections, query, key } = options;
  const name = collections.concat(key || parseInt(Math.random() * 10000)).join('_');
  watchedRecords.value.push(name);
  Records.view({
    name,
    collections,
    query
  });
};

const openIfPinned = () => {
  open.value = !!Session.isSignedIn() && 
    display.lgAndUp.value && 
    (Session.user().experiences['sidebar'] === undefined || Session.user().experiences['sidebar'] === true);
};

const fetchData = () => {
  Records.users.findOrFetchGroups().then(() => {
    if (route.path === "/dashboard") {
      if (Session.user().groups().length === 0) {
        router.replace("/g/new");
      }
      if (Session.user().groups().length === 1) {
        router.replace(`/g/${Session.user().groups()[0].key}`);
      }
    }
  });
  InboxService.load();
};

const updateGroups = () => {
  organizations.value = compact(Session.user().parentGroups().concat(Session.user().orphanParents())) || [];
  openCounts.value = {};
  openGroups.value = [];
  Session.user().groups().forEach(g => {
    openCounts.value[g.id] = g.discussions().filter(discussion => discussion.isUnread()).length;
  });
  Session.user().parentGroups().forEach(g => {
    if (organization.value && (organization.value.id === g.parentOrSelf().id)) {
      openGroups.value[g.id] = true;
    }
  });
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

watchRecordsFunc({
  collections: ['groups', 'memberships', 'discussions', 'polls', 'stances'],
  query: () => {
    unreadDirectThreadsCount.value = Records.discussions.collection.chain()
      .find({groupId: null})
      .where(thread => thread.isUnread())
      .data().length;
    updateGroups();
  }
});

EventBus.$on('signedIn', u => {
  user.value = Session.user();
  fetchData();
  openIfPinned();
});

if (Session.isSignedIn()) {
  fetchData();
}

onMounted(() => {
  openIfPinned();
});

onUnmounted(() => {
  watchedRecords.value.forEach(name => delete Records.views[name]);
});

// Watchers
watch(organization, () => {
  updateGroups();
});

watch(open, (val) => {
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
        v-list-item-title(:class="{'text-medium-emphasis': pollsToVoteOnCount() === 0}") {{ $t('dashboard_page.polls_to_vote_on_count', {count: pollsToVoteOnCount()}) }}
      v-list-item(to="/inbox")
        v-list-item-title(:class="{'text-medium-emphasis': unreadThreadCount() === 0}") {{ $t('sidebar.unread_discussions_count', {count: unreadThreadCount()}) }}
      v-list-item.sidebar__list-item-button--private(to="/threads/direct")
        v-list-item-title
          span(v-t="'sidebar.invite_only_discussions'")
          span(v-if="unreadDirectThreadsCount > 0")
            space
            span ({{unreadDirectThreadsCount}})
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
