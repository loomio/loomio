<script setup lang="js">
import { computed, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRoute, useRouter } from 'vue-router';
import EventBus from '@/shared/services/event_bus';
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import GroupAbility from '@/shared/abilities/group_ability';
import { unreadCutoffDate } from '@/shared/helpers/unread_cutoff.mjs';

const { group } = defineProps({ group: Object });
const { t } = useI18n();
const route = useRoute();
const router = useRouter();
const inviteClicked = ref(false);

const canAddMembers = computed(() => GroupAbility.canAddMembers(group));
const highlightInvite = computed(() => canAddMembers.value && (group.membershipsCount || 0) < 3 && !inviteClicked.value);

const basePath = computed(() => (group.handle ? `/${group.handle}` : `/g/${group.key}`));
const threadsRoute = computed(() => basePath.value);
const membersRoute = computed(() => `${basePath.value}/members`);
const pollsRoute = computed(() => `${basePath.value}/polls`);
const filesRoute = computed(() => `${basePath.value}/files`);

const activeSection = computed(() => {
  const segments = (route?.path || '').split('/').filter(Boolean);
  if (segments.includes('members')) { return 'members'; }
  if (segments.includes('polls')) { return 'polls'; }
  if (segments.includes('files')) { return 'files'; }
  if (segments.includes('stats') || segments.includes('participation_report') ||
      segments.includes('membership_requests') || segments.includes('emails') || segments.includes('tags')) { return null; }
  return 'threads';
});

const recentTopics = computed(() => {
  if (!Records.topics?.collection) { return []; }
  const recentCutoff = unreadCutoffDate();
  return Records.topics.collection
    .chain()
    .find({ groupId: group.id, discardedAt: null, lastActivityAt: { $gt: recentCutoff } })
    .data();
});
const recentThreadsCount = computed(() => recentTopics.value.length);
const unreadThreadsCount = computed(() => recentTopics.value.filter(topic => topic.isUnread()).length);
const membersSubtitle = computed(() => {
  const membersCount = group.membershipsCount || 0;
  const parts = [t('group_cards.members_count', { count: membersCount }, membersCount)];
  if (group.delegatesCount > 0) {
    parts.push(t('group_cards.delegates_count', { count: group.delegatesCount }, group.delegatesCount));
  }
  return parts.join(', ');
});
const votesNeededCount = computed(() => group.currentUserVotesNeededCount || 0);
const openPollsCount = computed(() => group.activePollsCount || 0);

function go(path) {
  router.push(path);
}

function invite() {
  inviteClicked.value = true;
  const allowed = Session.user().emailInvitationsAllowed() || group.emailInvitationsAllowed();
  const component = allowed ? 'GroupInvitationForm' : 'GroupShareableLinkForm';
  EventBus.$emit('openModal', { component, props: { group } });
}
</script>

<template lang="pug">
.group-cards.my-4
  v-row(density="compact")
    v-col(cols="6" md="3")
      v-card.group-cards__threads.group-page-discussions-tab.fill-height(
        variant="tonal"
        :color="activeSection === 'threads' ? 'primary' : undefined"
        :active="false"
        :to="threadsRoute"
      )
        v-card-text.d-flex.align-center.ga-3.pa-3
          common-icon(name="mdi-forum")
          div
            .text-title-small {{ t('group_cards.threads') }}
            .text-body-small.text-medium-emphasis
              a.group-cards__recent-link.text-decoration-none.underline-on-hover.text-medium-emphasis(
                :href="threadsRoute"
                @click.prevent.stop="go(threadsRoute)"
              ) {{ t('group_cards.recent_count', { count: recentThreadsCount }) }}
              span.mx-1 ·
              a.group-cards__unread-link.text-decoration-none.underline-on-hover(
                :href="threadsRoute + '?unread=1'"
                :class="unreadThreadsCount > 0 || route.query.unread ? 'text-primary font-weight-medium' : 'text-medium-emphasis'"
                @click.prevent.stop="go(threadsRoute + '?unread=1')"
              ) {{ t('dashboard_cards.unread_count', { count: unreadThreadsCount }) }}
    v-col(cols="6" md="3")
      v-card.group-cards__polls.group-page-polls-tab.fill-height(
        variant="tonal"
        :color="activeSection === 'polls' ? 'primary' : undefined"
        :active="false"
        :to="pollsRoute"
      )
        v-card-text.d-flex.align-center.ga-3.pa-3
          common-icon(name="mdi-poll")
          div
            .text-title-small {{ t('group_page.polls') }}
            .text-body-small.text-medium-emphasis
              a.group-cards__need-vote-link.text-decoration-none.underline-on-hover(
                :href="pollsRoute + '?status=vote'"
                :class="votesNeededCount > 0 || route.query.status === 'vote' ? 'text-primary font-weight-medium' : 'text-medium-emphasis'"
                @click.prevent.stop="go(pollsRoute + '?status=vote')"
              ) {{ t('group_cards.need_vote_count', { count: votesNeededCount }) }}
              span.mx-1 ·
              a.group-cards__open-polls-link.text-decoration-none.underline-on-hover(
                :href="pollsRoute + '?status=active'"
                :class="route.query.status === 'active' ? 'text-primary font-weight-medium' : 'text-medium-emphasis'"
                @click.prevent.stop="go(pollsRoute + '?status=active')"
              ) {{ t('group_cards.open_count', { count: openPollsCount }) }}
    v-col(cols="6" md="3")
      v-card.group-cards__members.group-page-members-tab.fill-height(
        variant="tonal"
        :color="activeSection === 'members' ? 'primary' : undefined"
        :active="false"
        :to="membersRoute"
      )
        v-card-text.d-flex.align-center.justify-space-between.flex-wrap.ga-2.pa-3
          .d-flex.align-center.ga-3
            common-icon(name="mdi-account-group")
            div
              .text-title-small {{ t('group_page.members') }}
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
    v-col(cols="6" md="3")
      v-card.group-cards__files.group-page-files-tab.fill-height(
        variant="tonal"
        :color="activeSection === 'files' ? 'primary' : undefined"
        :active="false"
        :to="filesRoute"
      )
        v-card-text.d-flex.align-center.ga-3.pa-3
          common-icon(name="mdi-file")
          div
            .text-title-small {{ t('group_page.files') }}
            .text-body-small.text-medium-emphasis {{ t('group_cards.browse_files') }}
</template>
