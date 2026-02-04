<script setup lang="js">
import { ref, onUnmounted } from 'vue';

import Session from '@/shared/services/session';
import Records from '@/shared/services/records';
import AbilityService from '@/shared/services/ability_service';
import LmoUrlService from '@/shared/services/lmo_url_service';
import { mdiPlus } from '@mdi/js';

const props = defineProps(['organization', 'openCounts']);

const urlFor = (model, action, params) => LmoUrlService.route({model, action, params});

const mine = ref([]);
const more = ref([]);
const canStartSubgroup = ref(false);
const watchedRecords = ref([]);

const watchRecords = (options) => {
  const { collections, query, key } = options;
  const name = collections.concat(key || parseInt(Math.random() * 10000)).join('_');
  watchedRecords.value.push(name);
  Records.view({ name, collections, query });
};

watchRecords({
  collections: ['groups', 'memberships'],
  query: () => {
    mine.value = props.organization.subgroups().filter(g => !g.archivedAt && g.membershipFor(Session.user()));
    more.value = props.organization.subgroups().filter(g => AbilityService.canViewGroup(g) && !g.membershipFor(Session.user()));
    canStartSubgroup.value = AbilityService.canCreateSubgroups(props.organization);
  }
});

onUnmounted(() => {
  watchedRecords.value.forEach(name => delete Records.views[name]);
});
</script>

<template lang="pug">
v-list.ma-0.pa-0.pb-2(v-if="mine.length || more.length || canStartSubgroup" nav density="compact" :lines="false")
  template(v-if="mine.length")
    v-list-subheader
      span(v-t="'group_page.my_subgroups'")

    v-list-item(v-for="group in mine" nav slim :to="urlFor(group)")
      v-list-item-title
        plain-text(:model="group" field="name")
        template(v-if='openCounts[group.id]')
          | &nbsp;
          span ({{openCounts[group.id]}})

  template(v-if="more.length")
    v-list-subheader
      span(v-if="mine.length" v-t="'group_page.more_subgroups'")
      span(v-else v-t="'group_page.subgroups'")

    v-list-item(v-for="group in more" nav slim :to="urlFor(group)")
      v-list-item-title
        plain-text(:model="group" field="name")
        template(v-if='openCounts[group.id]')
          | &nbsp;
          span ({{openCounts[group.id]}})

  v-btn.sidebar-start-subgroup.mb-2(
    size="small"
    block
    variant="tonal"
    color="primary"
    v-if="canStartSubgroup"
    :to="'/g/new?parent_id='+organization.id"
  )
    span(v-t="'group_form.new_subgroup'")

</template>
