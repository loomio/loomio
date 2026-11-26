<script setup lang="js">
import { computed, onBeforeUnmount, ref, watch } from 'vue';
import { useRoute } from 'vue-router';
import { pickBy } from 'lodash-es';
import Session from '@/shared/services/session';
import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import GroupService from '@/shared/services/group_service';
import LmoUrlService from '@/shared/services/lmo_url_service';
import GroupCards from '@/components/group/cards.vue';
import GroupsFilterMenu from '@/components/dashboard/groups_filter_menu.vue';

const route = useRoute();
const group = ref(null);

const dockActions = computed(() => pickBy(GroupService.actions(group.value), v => v.dock));

function urlFor(model) {
  return LmoUrlService.route({ model });
}

function titleVisible(visible) {
  EventBus.$emit('content-title-visible', visible);
}

function init() {
  const existing = typeof Records.groups.fuzzyFind === 'function' ? Records.groups.fuzzyFind(route.params.key) : null;
  group.value = existing || null;
  Records.groups.findOrFetch(route.params.key).then(fetched => {
    group.value = fetched;
    if (group.value.newHost) { window.location.host = group.value.newHost; }
  }).catch(error => {
    EventBus.$emit('pageError', error);
    if ((error.status === 403) && !Session.isSignedIn()) { EventBus.$emit('openAuthModal'); }
  });
}

init();
EventBus.$on('signedIn', init);
EventBus.$on('joinedGroup', init);

onBeforeUnmount(() => {
  EventBus.$off('signedIn', init);
  EventBus.$off('joinedGroup', init);
});

watch(() => route.params.key, init);

defineExpose({ group });
</script>

<template lang="pug">
v-main
  loading(v-if="!group")
  v-container.group-page.max-width-1024.px-2.px-sm-4(v-if="group")
    div(v-if="group.coverUrl" style="position: relative")
      v-img(
        :src="group.coverUrl"
        :aspect-ratio="4"
        style="border-radius: 8px"
        max-height="256"
        cover
        eager
      )
    .d-flex.align-center.justify-space-between.flex-wrap.ga-2.my-4
      groups-filter-menu(:current-group="group")
        h1.text-headline-large(tabindex="-1" v-intersect="{handler: titleVisible}")
          span(v-if="group && group.parentId")
            router-link.text-high-emphasis.text-decoration-none.underline-on-hover(:to="urlFor(group.parent())" @click.stop)
              plain-text(:model="group.parent()" field="name")
            space
            span.text-medium-emphasis.text--lighten-1 &gt;
            space
          plain-text.group-page__name(:model="group" field="name")
      action-dock.group-page__actions(
        v-if="Object.keys(dockActions).length > 0"
        :model="group"
        :actions="dockActions"
      )
    formatted-text.group-page__description(
      v-if="group"
      :model="group"
      field="description"
    )
    link-previews(:model="group")
    join-group-button(:group="group")
    group-follow-button(:group="group")
    attachment-list(:attachments="group.attachments")
    plan-banner(:group="group")
    group-cards(:group="group")
    .group-page__panel
      router-view
</template>

<style scoped>
.group-page__panel {
  min-height: calc(100vh - 160px);
}
</style>
