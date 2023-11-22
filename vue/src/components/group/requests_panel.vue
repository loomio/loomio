<script lang="js">
import Records        from '@/shared/services/records';
import AbilityService from '@/shared/services/ability_service';
import RecordLoader   from '@/shared/services/record_loader';
import Session        from '@/shared/services/session';
import { orderBy } from 'lodash-es';
import LmoUrlService from '@/shared/services/lmo_url_service';
import { exact, approximate } from '@/shared/helpers/format_time';

export default
{
  data() {
    return {
      requests: [],
      group: null
    };
  },

  created() {
    Records.groups.findOrFetch(this.$route.params.key).then(group => {
      this.group = group;

      if (AbilityService.canManageMembershipRequests(this.group)) {
        Records.membershipRequests.fetchPendingByGroup(this.group.key, {per: 100});
        Records.membershipRequests.fetchPreviousByGroup(this.group.key, {per: 100});
        this.watchRecords({
          collections: ['membershipRequests'],
          query: store => {this.requests = this.group.membershipRequests(); }
        });
      }
    });
  },

  computed: {
    unapprovedRequestsByOldestFirst() {
      const unapproved = this.requests.filter(request => !request.respondedAt);
      return orderBy(unapproved, ['createdAt'], ['asc']);
    },

    approvedRequestsByNewestFirst() {
      const approved = this.requests.filter(request => request.respondedAt);
      return orderBy(approved, ['respondedAt'], ['desc']);
    }
  }
};
</script>
<template lang="pug">
.requests-panel
  h2.ma-4.headline(v-t="'membership_requests_card.heading'")
  loading(v-if="!group")
  v-card.mt-4(outlined v-else="group")
    p.text-center.pa-4(v-if="!requests.length" v-t="'common.no_results_found'")
    v-list(two-line)
      membership-request(v-for="request in unapprovedRequestsByOldestFirst" :request="request" :key="request.id")
      membership-request(v-for="request in approvedRequestsByNewestFirst" :request="request" :key="request.id")
</template>
