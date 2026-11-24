<script setup lang="js">
import { computed, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import EventBus from '@/shared/services/event_bus';
import LmoUrlService from '@/shared/services/lmo_url_service';
import Session from '@/shared/services/session';
import GroupAbility from '@/shared/abilities/group_ability';
import GroupOnboardingCard from '@/components/group/onboarding_card.vue';

const { group } = defineProps({ group: Object });
const { t } = useI18n();
const inviteClicked = ref(false);

const canAddMembers = computed(() => GroupAbility.canAddMembers(group));
const highlightInvite = computed(() => canAddMembers.value && (group.membershipsCount || 0) < 3 && !inviteClicked.value);
const membersRoute = computed(() => LmoUrlService.route({ model: group, action: 'members' }));
const pollsRoute = computed(() => LmoUrlService.route({ model: group, action: 'polls' }));
const filesRoute = computed(() => LmoUrlService.route({ model: group, action: 'files' }));
const membersTitle = computed(() => {
  const membersCount = group.membershipsCount || 0;
  return t('group_cards.members_count', { count: membersCount }, membersCount);
});
const membersSubtitle = computed(() => {
  const parts = [];
  if (group.adminMembershipsCount > 0) {
    parts.push(t('group_cards.admins_count', { count: group.adminMembershipsCount }, group.adminMembershipsCount));
  }
  if (group.delegatesCount > 0) {
    parts.push(t('group_cards.delegates_count', { count: group.delegatesCount }, group.delegatesCount));
  }
  return parts.join(', ');
});
const pollsTitle = computed(() => {
  const pollsCount = group.pollsCount || 0;
  return pollsCount > 0 ? t('group_cards.polls_count', { count: pollsCount }, pollsCount) : t('group_page.polls');
});
const pollsSubtitle = computed(() => {
  const votesNeeded = group.currentUserVotesNeededCount || 0;
  if (votesNeeded > 0) {
    return t('group_cards.needs_your_vote', { count: votesNeeded }, votesNeeded);
  }
  const proposals = group.proposalsCount || 0;
  const otherPolls = Math.max(0, (group.pollsCount || 0) - proposals);
  const parts = [];
  if (proposals > 0) { parts.push(t('group_cards.proposals_count', { count: proposals }, proposals)); }
  if (otherPolls > 0) { parts.push(t('group_cards.polls_count', { count: otherPolls }, otherPolls)); }
  return parts.length ? parts.join(', ') : t('group_cards.no_open_polls');
});

function invite() {
  inviteClicked.value = true;
  const allowed = Session.user().emailInvitationsAllowed() || group.emailInvitationsAllowed();
  const component = allowed ? 'GroupInvitationForm' : 'GroupShareableLinkForm';
  EventBus.$emit('openModal', { component, props: { group } });
}
</script>

<template lang="pug">
.group-cards.my-4
  group-onboarding-card(:group="group")
  v-row(density="compact")
    v-col(cols="12" sm="4")
      v-card.group-cards__members.group-page-members-tab(variant="outlined" :to="membersRoute")
        v-card-text.d-flex.align-center.justify-space-between.pa-3
          .d-flex.align-center.ga-3
            common-icon(name="mdi-account-group")
            div
              .text-title-small {{ membersTitle }}
              .text-body-small.text-medium-emphasis(v-if="membersSubtitle") {{ membersSubtitle }}
          v-tooltip(
            v-if="canAddMembers"
            :model-value="highlightInvite"
            :open-on-hover="!highlightInvite"
            :disabled="!highlightInvite"
            location="bottom"
            :text="t('group_cards.invite_get_started')"
          )
            template(#activator="{ props }")
              v-btn.group-cards__invite(
                v-bind="props"
                color="primary"
                variant="tonal"
                size="small"
                @click.prevent.stop="invite"
              ) {{ t('common.action.invite') }}
    v-col(cols="6" sm="4")
      v-card.group-cards__polls.group-page-polls-tab(variant="outlined" :to="pollsRoute")
        v-card-text.d-flex.align-center.ga-3.pa-3
          common-icon(name="mdi-poll")
          div
            .text-title-small {{ pollsTitle }}
            .text-body-small(v-if="pollsSubtitle" :class="group.currentUserVotesNeededCount > 0 ? 'text-primary font-weight-medium' : 'text-medium-emphasis'") {{ pollsSubtitle }}
    v-col(cols="6" sm="4")
      v-card.group-cards__files.group-page-files-tab(variant="outlined" :to="filesRoute")
        v-card-text.d-flex.align-center.ga-3.pa-3
          common-icon(name="mdi-file")
          div
            .text-title-small {{ t('group_page.files') }}
            .text-body-small.text-medium-emphasis {{ t('group_cards.browse_files') }}
</template>
