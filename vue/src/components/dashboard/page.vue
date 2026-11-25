<script setup>
import { onMounted } from 'vue';
import EventBus from '@/shared/services/event_bus';
import GroupsFilterMenu from '@/components/dashboard/groups_filter_menu.vue';

function titleVisible(visible) {
  EventBus.$emit('content-title-visible', visible);
}

function openSearchModal() {
  EventBus.$emit('openModal', {
    component: 'SearchModal',
    persistent: false,
    maxWidth: 900,
    props: { group: null, discussion: null }
  });
}

onMounted(() => {
  EventBus.$emit('content-title-visible', false);
  EventBus.$emit('currentComponent', {
    titleKey: 'dashboard_cards.all_groups',
    page: 'dashboardPage',
    group: null
  });
});
</script>

<template lang="pug">
v-main
  v-container.dashboard-page.max-width-1024.px-2.px-sm-4
    .my-4
      groups-filter-menu
        h1.text-headline-large(tabindex="-1" v-intersect="{handler: titleVisible}" v-t="'dashboard_cards.all_groups'")
    dashboard-cards

    v-text-field.dashboard-page__mobile-search.mb-3(
      v-if="$vuetify.display.smAndDown"
      readonly
      hide-details
      variant="solo-filled"
      prepend-inner-icon="mdi-magnify"
      :label="$t('common.action.search')"
      @click="openSearchModal"
      @keydown.enter="openSearchModal"
    )

    router-view
</template>
