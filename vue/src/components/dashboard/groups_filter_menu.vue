<script setup lang="js">
import { computed, ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRoute } from 'vue-router';
import { sortBy } from 'lodash-es';
import { mdiMagnify } from '@mdi/js';
import Session from '@/shared/services/session';

const { section } = defineProps({
  section: { type: String, default: '' }
});
const { t } = useI18n();
const route = useRoute();
const open = ref(false);
const filter = ref('');

const CARRIED_THREAD_FILTERS = new Set(['unread', 'locked', 'all']);

const groups = computed(() => sortBy(Session.user().groups(), g => (g.fullName || g.name || '').toLowerCase()));
const filteredGroups = computed(() => {
  const query = filter.value.trim().toLowerCase();
  if (!query) { return groups.value; }
  return groups.value.filter(g => (g.fullName || g.name || '').toLowerCase().includes(query));
});

watch(open, isOpen => {
  if (!isOpen) { filter.value = ''; }
});

function groupRoute(group) {
  const base = group.handle ? `/${group.handle}` : `/g/${group.key}`;
  const path = section ? `${base}/${section}` : base;
  const query = !section && CARRIED_THREAD_FILTERS.has(route.query?.t) ? { t: route.query.t } : {};
  return { path, query };
}
</script>

<template lang="pug">
v-menu(v-if="groups.length > 0" v-model="open" :close-on-content-click="false")
  template(#activator="{ props }")
    v-btn.groups-filter-menu__button.text-medium-emphasis(v-bind="props" variant="tonal")
      span {{ t('common.groups') }}
      common-icon(name="mdi-menu-down" color="currentColor")
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
      v-list-item.groups-filter-menu__all(:active="true" @click="open = false")
        v-list-item-title {{ t('dashboard_cards.all_groups') }}
      v-divider.my-1
      v-list-item.groups-filter-menu__group(
        v-for="group in filteredGroups"
        :key="group.id"
        :to="groupRoute(group)"
        @click="open = false"
      )
        v-list-item-title {{ group.fullName || group.name }}
</template>
