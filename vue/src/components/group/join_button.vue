<script lang="js">
import Session         from '@/shared/services/session';
import Records         from '@/shared/services/records';
import EventBus        from '@/shared/services/event_bus';
import AbilityService  from '@/shared/services/ability_service';
import Flash           from '@/shared/services/flash';
import WatchRecords    from '@/mixins/watch_records';
import { useI18n }     from 'vue-i18n';

export default
{
  mixins: [WatchRecords],
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
      membership: null,
      membershipRequest: null,
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

    this.watchRecords({
      collections: ['memberships', "membershipRequests"],
      query: () => {
        const requests = this.group.membershipRequests()
          .filter(request => request.requestorId === Session.user().id);
        this.membershipRequest = requests.find(request => request.isPending()) ||
          requests.sort((a, b) => (b.createdAt || '').localeCompare(a.createdAt || ''))[0];
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
      return this.group && !!AbilityService.canJoinGroup(this.group);
    },

    canRequestMembership() {
      return this.membershipRequestLoaded &&
        !this.wasIgnored &&
        !!AbilityService.canRequestMembership(this.group);
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
    :disabled="hasRequestedMembership"
  ) {{ t(label) }}
</template>
