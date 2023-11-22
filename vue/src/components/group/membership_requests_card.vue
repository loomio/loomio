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

<template>

<v-card class="membership-requests-card" v-if="canManageMembershipRequests() && membershipRequests.length">
  <v-list two-line="two-line" avatar="avatar">
    <v-subheader v-t="'membership_requests_card.heading'"></v-subheader>
    <v-list-item class="membership-requests-card__request" v-for="request in orderedPendingMembershipRequests()" :key="request.id" :to="urlFor(group, 'membership_requests')">
      <v-list-item-avatar>
        <user-avatar :user="request.actor()" :size="40"></user-avatar>
      </v-list-item-avatar>
      <v-list-item-content>
        <v-list-item-title class="membership-requests-card__requestor-name">{{request.actor().name || request.actor().email}}</v-list-item-title>
        <v-list-item-subtitle class="membership-requests-card__requestor-introduction">{{request.introduction}}</v-list-item-subtitle>
      </v-list-item-content>
    </v-list-item>
  </v-list>
  <v-card-actions>
    <v-btn class="membership-requests-card__link" text="text" :to="urlFor(group, 'membership_requests')"><span v-t="{ path: 'membership_requests_card.manage_requests_with_count', args: { count: group.pendingMembershipRequests().length } }"></span></v-btn>
  </v-card-actions>
</v-card>
</template>
<style lang="sass">
.membership-requests-card__request-link
	margin: 0
	padding: 8px 0
	width: 100%
	text-transform: none
	text-align: left

</style>
