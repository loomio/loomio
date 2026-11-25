<script setup lang="js">
import { computed } from 'vue';
import { useRoute } from 'vue-router';

import Session from '@/shared/services/session';
import Records from '@/shared/services/records';
import GroupAbility from '@/shared/abilities/group_ability';
import LmoUrlService from '@/shared/services/lmo_url_service';
import { mdiPlus } from '@mdi/js';

const props = defineProps(['organization', 'openCounts', 'activeGroupId']);
const route = useRoute();

const CARRIED_THREAD_FILTERS = new Set(['locked', 'all']);
const groupLink = (model) => {
  const query = {};
  if (CARRIED_THREAD_FILTERS.has(route.query?.t)) { query.t = route.query.t; }
  if (route.query?.unread) { query.unread = '1'; }
  return { path: LmoUrlService.route({ model }), query };
};

const mine = computed(() => props.organization.subgroups().filter(g => !g.isDiscarded() && g.membershipFor(Session.user())));
const more = computed(() => props.organization.subgroups().filter(g => GroupAbility.canShow(g) && !g.membershipFor(Session.user())));
const canStartSubgroup = computed(() => GroupAbility.canAddSubgroup(props.organization));
</script>

<template lang="pug">
.sidebar__subgroups(v-if="mine.length || more.length || canStartSubgroup")
  v-list.ma-0.pa-0(nav density="compact" :lines="false")
    v-list-item.sidebar__group.sidebar__subgroup(v-for="group in mine" :key="group.id" nav slim :to="groupLink(group)" :active="activeGroupId === group.id")
      v-list-item-title.font-weight-regular
        plain-text(:model="group" field="name")
      template(v-slot:append v-if="openCounts[group.id]")
        span.text-caption.text-medium-emphasis {{ openCounts[group.id] }}

    v-list-item.sidebar__group.sidebar__subgroup(v-for="group in more" :key="group.id" nav slim :to="groupLink(group)" :active="activeGroupId === group.id")
      v-list-item-title.font-weight-regular
        plain-text(:model="group" field="name")
      template(v-slot:append v-if="openCounts[group.id]")
        span.text-caption.text-medium-emphasis {{ openCounts[group.id] }}

    v-btn.sidebar-start-subgroup.mt-1.mb-1(
      size="small"
      block
      variant="tonal"
      color="primary"
      v-if="canStartSubgroup"
      :to="'/g/new?parent_id='+organization.id"
    )
      span(v-t="'group_form.new_subgroup'")
</template>

<style scoped>
.sidebar__subgroups {
  margin: 2px 0 6px 19px;
  padding-left: 19px;
  border-left: 2px solid rgba(var(--v-border-color), var(--v-border-opacity));
}
</style>
