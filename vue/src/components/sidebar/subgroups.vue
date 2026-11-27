<script setup lang="js">
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRoute } from 'vue-router';

import Session from '@/shared/services/session';
import GroupAbility from '@/shared/abilities/group_ability';
import LmoUrlService from '@/shared/services/lmo_url_service';
import SidebarActivityLinks from '@/components/sidebar/activity_links.vue';

const { organization, openCounts = {}, votesNeededCounts = {}, activeGroupId } = defineProps([
  'organization',
  'openCounts',
  'votesNeededCounts',
  'activeGroupId'
]);
const { t } = useI18n();
const route = useRoute();

const CARRIED_THREAD_FILTERS = new Set(['locked', 'all']);
const groupLink = (model) => {
  const query = {};
  if (CARRIED_THREAD_FILTERS.has(route.query?.t)) { query.t = route.query.t; }
  return { path: LmoUrlService.route({ model }), query };
};

function hasActivity(unread, votes) {
  return (unread || 0) > 0 || (votes || 0) > 0;
}

function urlFor(model) {
  return LmoUrlService.route({ model });
}

const mine = computed(() => organization.subgroups().filter(g => !g.isDiscarded() && g.membershipFor(Session.user())));
const more = computed(() => organization.subgroups().filter(g => GroupAbility.canShow(g) && !g.membershipFor(Session.user())));
const canStartSubgroup = computed(() => GroupAbility.canAddSubgroup(organization));
</script>

<template lang="pug">
.sidebar__subgroups(v-if="mine.length || more.length || canStartSubgroup")
  v-list.ma-0.pa-0(nav density="compact" :lines="false")
    v-list-item.sidebar__group.sidebar__subgroup(
      v-for="group in mine"
      :key="group.id"
      nav
      slim
      :to="groupLink(group)"
      :active="activeGroupId === group.id"
      :lines="hasActivity(openCounts[group.id], votesNeededCounts[group.id]) ? 'two' : false"
    )
      v-list-item-title.font-weight-regular
        plain-text(:model="group" field="name")
      sidebar-activity-links(
        :unread="openCounts[group.id] || 0"
        :votes="votesNeededCounts[group.id] || 0"
        :base-path="urlFor(group)"
      )

    v-list-item.sidebar__group.sidebar__subgroup(
      v-for="group in more"
      :key="group.id"
      nav
      slim
      :to="groupLink(group)"
      :active="activeGroupId === group.id"
      :lines="hasActivity(openCounts[group.id], votesNeededCounts[group.id]) ? 'two' : false"
    )
      v-list-item-title.font-weight-regular
        plain-text(:model="group" field="name")
      sidebar-activity-links(
        :unread="openCounts[group.id] || 0"
        :votes="votesNeededCounts[group.id] || 0"
        :base-path="urlFor(group)"
      )

    v-btn.sidebar-start-subgroup.mt-1.mb-1(
      size="small"
      block
      variant="tonal"
      color="primary"
      v-if="canStartSubgroup"
      :to="'/g/new?parent_id='+organization.id"
    )
      span {{ t('group_form.new_subgroup') }}
</template>

<style scoped>
.sidebar__subgroups {
  margin: 2px 0 6px 19px;
  padding-left: 19px;
  border-left: 2px solid rgba(var(--v-border-color), var(--v-border-opacity));
}
</style>
