<script setup>
import { computed, ref } from 'vue';
import Records from '@/shared/services/records';
import AbilityService from '@/shared/services/ability_service';
import { orderBy } from 'lodash-es';
import { useWatchRecords } from '@/composables/useWatchRecords';

const { group } = defineProps({
  group: {type: Object, required: true}
});
const requests = ref([]);
const { watchRecords } = useWatchRecords();

const unapprovedRequestsByOldestFirst = computed(() => {
  const unapproved = requests.value.filter(request => !request.respondedAt);
  return orderBy(unapproved, ['createdAt'], ['asc']);
});

const approvedRequestsByNewestFirst = computed(() => {
  const approved = requests.value.filter(request => request.respondedAt);
  return orderBy(approved, ['respondedAt'], ['desc']);
});

if (AbilityService.canManageMembershipRequests(group)) {
  Records.membershipRequests.fetchPendingByGroup(group.key, {per: 100});
  Records.membershipRequests.fetchPreviousByGroup(group.key, {per: 100});
  watchRecords({
    collections: ['membershipRequests'],
    query: () => { requests.value = group.membershipRequests(); }
  });
}
</script>
<template lang="pug">
.requests-panel
  h2.ma-4.text-headline-small(v-t="'membership_requests_card.heading'")
  loading(v-if="!group")
  v-card.mt-4(variant="outlined" v-else="group")
    p.text-center.pa-4(v-if="!requests.length" v-t="'common.no_results_found'")
    v-list(lines="two")
      membership-request(v-for="request in unapprovedRequestsByOldestFirst" :request="request" :key="request.id")
      membership-request(v-for="request in approvedRequestsByNewestFirst" :request="request" :key="request.id")
</template>
