<script lang="js">
import Session         from '@/shared/services/session';
import Records         from '@/shared/services/records';
import EventBus        from '@/shared/services/event_bus';
import GroupAbility from '@/shared/abilities/group_ability';
import Flash           from '@/shared/services/flash';
import { useI18n }     from 'vue-i18n';

export default
{
  props: {
    group: {
      required: true,
      type: Object
    },

    block: Boolean
  },

  setup() {
    const { t } = useI18n();
    return { t };
  },

  data() {
    return {
      membershipRequestLoaded: !Session.isSignedIn()
    };
  },

  created() {
    if (Session.isSignedIn() && !Session.user().membershipFor(this.group)) {
      Records.membershipRequests.fetchMineByGroup(this.group.id)
        .finally(() => { this.membershipRequestLoaded = true; });
    } else {
      this.membershipRequestLoaded = true;
    }
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
    membership() {
      return Session.user().membershipFor(this.group);
    },

    membershipRequest() {
      const requests = this.group.membershipRequests()
        .filter(request => request.requestorId === Session.userId);
      return requests.find(request => request.isPending()) ||
        requests.sort((a, b) => (b.createdAt || '').localeCompare(a.createdAt || ''))[0];
    },

    label() {
      if (this.hasRequestedMembership && !this.canJoinGroup) {
        return 'join_group_button.membership_requested';
      } else if (this.declineReason) {
        return 'join_group_button.request_membership_again';
      } else {
        return 'join_group_button.join_group';
      }
    },

    hasRequestedMembership() {
      return this.membershipRequest?.isPending();
    },

    declineReason() {
      return this.membershipRequest?.declineReason;
    },

    wasIgnored() {
      return !!this.membershipRequest?.declinedAt && !this.declineReason;
    },

    canJoinGroup() {
      if (!this.group || this.group.membersInclude(Session.user())) { return false; }
      // Visitors see the button so they can sign in, then the server rule applies.
      if (!Session.isSignedIn()) {
        return this.group.isEnabled() && this.group.membershipGrantedUpon === 'request' && GroupAbility.canShow(this.group);
      }
      return GroupAbility.canJoin(this.group);
    },

    canRequestMembership() {
      return this.membershipRequestLoaded &&
        !this.wasIgnored &&
        !this.group.membersInclude(Session.user()) && !this.canJoinGroup &&
        GroupAbility.canRequestMembership(this.group);
    }
  }
};

</script>

<template lang="pug">
v-alert.my-4.text-center(
  variant="tonal"
  density="compact"
  color="info"
  v-if="!membership && (canJoinGroup || canRequestMembership || hasRequestedMembership)"
)
  p.pb-4(v-if="declineReason") {{ t('join_group_button.membership_request_declined', { reason: declineReason }) }}
  p.pb-4(v-else) {{ t('join_group_button.not_a_member') }}
  v-btn.join-group-button(
    v-if="canJoinGroup || canRequestMembership || hasRequestedMembership"
    color="primary"
    @click="join"
    :disabled="hasRequestedMembership && !canJoinGroup"
  ) {{ t(label) }}
</template>
