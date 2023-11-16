<script lang="js">
import Session         from '@/shared/services/session';
import Records         from '@/shared/services/records';
import EventBus        from '@/shared/services/event_bus';
import AbilityService  from '@/shared/services/ability_service';
import Flash           from '@/shared/services/flash';

export default
{
  props: {
    group: {
      required: true,
      type: Object
    },

    block: Boolean
  },

  data() {
    return {
      membership: null,
      hasRequestedMembership: false
    };
  },

  created() {
    if (!Session.user().membershipFor(this.group)) {
      Records.membershipRequests.fetchMyPendingByGroup(this.group.id);
    }

    this.watchRecords({
      collections: ['memberships', "membershipRequests"],
      query: () => {
        this.hasRequestedMembership = this.group.hasPendingMembershipRequestFrom(Session.user());
        return this.membership = Session.user().membershipFor(this.group);
      }
    });
  },

  methods: {
    join() {
      if (Session.isSignedIn()) {
        if (this.canJoinGroup) {
          return Records.memberships.joinGroup(this.group).then(() => {
            EventBus.$emit('joinedGroup', {group: this.group});
            Flash.success('join_group_button.messages.joined_group', {group: this.group.fullName});
          });
        } else {
          EventBus.$emit('openModal', {
                          component: 'MembershipRequestForm',
                          props: { group: this.group }
                        });
        }
      } else {
        EventBus.$emit('openModal', {component: 'AuthModal'});
      }
    }
  },

  computed: {
    label() {
      if (this.hasRequestedMembership) {
        return 'join_group_button.membership_requested';
      } else {
        return 'join_group_button.join_group';
      }
    },

    canJoinGroup() {
      return this.group && AbilityService.canJoinGroup(this.group);
    },

    canRequestMembership() {
      return AbilityService.canRequestMembership(this.group);
    }
  }
};

</script>

<template lang="pug">
v-alert.my-4(outlined color="primary" dense v-if="!membership")
  p.text-center(v-t="'join_group_button.not_a_member'")
  v-btn.join-group-button(
    v-if="canJoinGroup || canRequestMembership || hasRequestedMembership"
    block color="primary" v-t="label" @click="join" :disabled="hasRequestedMembership")
</template>
