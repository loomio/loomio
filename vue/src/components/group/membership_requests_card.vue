<script lang="js">
import Records        from '@/shared/services/records';
import AbilityService from '@/shared/services/ability_service';
import { slice, orderBy } from 'lodash-es';

export default
{
  props: {
    group: Object
  },
  data() {
    return {membershipRequests: []};
  },
  created() {
    this.watchRecords({
      collections: ['membershipRequests'],
      query: store => {
        this.membershipRequests = this.group.pendingMembershipRequests();
      }
    });
    this.init();
  },
  methods: {
    init() {
      if (this.canManageMembershipRequests()) {
        Records.membershipRequests.fetchPendingByGroup(this.group.key);
      }
    },

    orderedPendingMembershipRequests() {
      return slice(orderBy(this.membershipRequests, 'createdAt', 'desc'), 0, 5);
    },

    canManageMembershipRequests() {
      return AbilityService.canManageMembershipRequests(this.group);
    }
  }
};
</script>

<template lang="pug">
v-card.membership-requests-card(v-if='canManageMembershipRequests() && membershipRequests.length')
  v-list(two-line avatar)
    v-subheader(v-t="'membership_requests_card.heading'")
    v-list-item.membership-requests-card__request(v-for='request in orderedPendingMembershipRequests()', :key='request.id' :to="urlFor(group, 'membership_requests')")
      v-list-item-avatar
        user-avatar(:user='request.actor()' :size='40')
      v-list-item-content
        v-list-item-title.membership-requests-card__requestor-name {{request.actor().name || request.actor().email}}
        v-list-item-subtitle.membership-requests-card__requestor-introduction {{request.introduction}}
  v-card-actions
    v-btn.membership-requests-card__link(text :to="urlFor(group, 'membership_requests')")
      span(v-t="{ path: 'membership_requests_card.manage_requests_with_count', args: { count: group.pendingMembershipRequests().length } }")
</template>
<style lang="sass">
.membership-requests-card__request-link
	margin: 0
	padding: 8px 0
	width: 100%
	text-transform: none
	text-align: left

</style>
