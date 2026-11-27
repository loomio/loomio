<script setup lang="js">
import { computed, ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRoute } from 'vue-router';
import { sortBy } from 'lodash-es';
import { mdiMagnify } from '@mdi/js';
import Session from '@/shared/services/session';
import GroupAbility from '@/shared/abilities/group_ability';
import { sidebarOpen } from '@/shared/services/sidebar_state';

const { currentGroup } = defineProps({
  currentGroup: { type: Object, default: null }
});
const { t } = useI18n();
const route = useRoute();
const open = ref(false);
const filter = ref('');

const CARRIED_THREAD_FILTERS = new Set(['locked', 'all']);

const groups = computed(() => {
  if (typeof Session.user !== 'function' || !Session.user()) { return []; }
  return sortBy(Session.user().groups(), g => (g.fullName || g.name || '').toLowerCase());
});
const interactive = computed(() => !sidebarOpen.value && groups.value.length > 0);
const canStartGroups = computed(() =>
  typeof GroupAbility.canCreate === 'function' && GroupAbility.canCreate()
);
const filteredGroups = computed(() => {
  const query = filter.value.trim().toLowerCase();
  if (!query) { return groups.value; }
  return groups.value.filter(g => (g.fullName || g.name || '').toLowerCase().includes(query));
});

const currentSection = computed(() => {
  const segments = (route?.path || '').split('/').filter(Boolean);
  if (segments.includes('polls') || segments.includes('polls_to_vote_on')) { return 'polls'; }
  if (segments.includes('members') || segments.includes('people')) { return 'members'; }
  if (segments.includes('tasks')) { return 'tasks'; }
  if (segments.includes('files')) { return 'files'; }
  if (segments.includes('bookmarks')) { return 'bookmarks'; }
  return '';
});

watch(open, isOpen => {
  if (!isOpen) { filter.value = ''; }
});

function carriedQuery() {
  const query = {};
  if (!currentSection.value) {
    if (CARRIED_THREAD_FILTERS.has(route?.query?.t)) { query.t = route.query.t; }
    if (route?.query?.unread) { query.unread = '1'; }
  }
  return query;
}

const dashboardRoute = computed(() => ({
  path: currentSection.value ? `/dashboard/${currentSection.value}` : '/dashboard',
  query: carriedQuery()
}));

function groupRoute(group) {
  const base = group.handle ? `/${group.handle}` : `/g/${group.key}`;
  const path = currentSection.value ? `${base}/${currentSection.value}` : base;
  return { path, query: carriedQuery() };
}
</script>

<template lang="pug">
v-menu(v-if="interactive" v-model="open" :close-on-content-click="false")
  template(#activator="{ props }")
    .groups-filter-menu__title-activator.d-inline-flex.align-center.ga-1(
      v-bind="props"
      role="button"
      tabindex="0"
      style="cursor: pointer"
    )
      slot
      common-icon.text-medium-emphasis(name="mdi-menu-down")
  v-card(min-width="240" max-width="360")
    .pa-2(v-if="groups.length > 8")
      v-text-field(
        v-model="filter"
        :placeholder="t('group_cards.filter_groups')"
        autofocus
        density="compact"
        hide-details
        :prepend-inner-icon="mdiMagnify"
        variant="outlined"
      )
    v-list(density="compact" max-height="60vh")
      template(v-if="groups.length !== 1")
        v-list-item.groups-filter-menu__all(slim :to="dashboardRoute" :active="!currentGroup" @click="open = false")
          template(v-slot:prepend)
            v-avatar(:size="22" color="transparent")
              common-icon(name="mdi-account-group" :size="18")
          v-list-item-title {{ t('dashboard_cards.all_groups') }}
        v-divider.my-1
      v-list-item.groups-filter-menu__group(
        v-for="group in filteredGroups"
        :key="group.id"
        slim
        :to="groupRoute(group)"
        :active="Boolean(currentGroup && currentGroup.id === group.id)"
        @click="open = false"
      )
        template(v-slot:prepend)
          group-avatar(:group="group" :size="22")
        v-list-item-title {{ group.fullName || group.name }}
      template(v-if="canStartGroups")
        v-divider.my-1
        v-list-item.groups-filter-menu__new(
          slim
          to="/g/new"
          @click="open = false"
        )
          template(v-slot:prepend)
            v-avatar(:size="22" color="transparent")
              common-icon(name="mdi-plus" :size="18")
          v-list-item-title {{ t('sidebar.new_group') }}
slot(v-else)
</template>
