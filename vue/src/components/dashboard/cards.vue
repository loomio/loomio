<script setup lang="js">
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRoute, useRouter } from 'vue-router';
import { unreadCutoffDate } from '@/shared/helpers/unread_cutoff.mjs';
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import { usePendingPolls } from '@/composables/usePendingPolls';
import { useBookmarks } from '@/composables/useBookmarks';

const { t } = useI18n();
const route = useRoute();
const router = useRouter();
const { loadPendingPolls, findPendingPolls } = usePendingPolls();
const { loadBookmarks } = useBookmarks();

loadPendingPolls();
loadBookmarks();

const activeSection = computed(() => {
  const path = route?.path || '';
  if (path.startsWith('/dashboard/polls')) { return 'polls'; }
  if (path.startsWith('/dashboard/members') || path.startsWith('/dashboard/people')) { return 'people'; }
  if (path.startsWith('/dashboard/tasks') || path.startsWith('/tasks')) { return 'tasks'; }
  if (path.startsWith('/dashboard/files')) { return 'files'; }
  if (path.startsWith('/dashboard/bookmarks') || path.startsWith('/bookmarks')) { return 'bookmarks'; }
  return 'threads';
});

const overflowActive = computed(() => ['files', 'bookmarks'].includes(activeSection.value));

function go(path) {
  router.push(path);
}

const unreadCounts = computed(() => {
  const counts = { total: 0, direct: 0 };
  const recentCutoff = unreadCutoffDate();
  Records.topics.collection
    .chain()
    .find({ discardedAt: null, lastActivityAt: { $gt: recentCutoff } })
    .where(topic => topic.isUnread())
    .data()
    .forEach(topic => {
      counts.total += 1;
      if (!topic.groupId) { counts.direct += 1; }
    });
  return counts;
});

const pendingPollsCount = computed(() => findPendingPolls().length);
const openPollsCount = computed(() => {
  const fromGroups = Session.user().groups().reduce((sum, g) => sum + (g.activePollsCount || 0), 0);
  return Math.max(fromGroups, pendingPollsCount.value);
});
const bookmarksCount = computed(() => Records.bookmarks.find({ userId: Session.userId, discardedAt: null }).length);
</script>

<template lang="pug">
.dashboard-cards.d-flex.align-stretch.ga-2.my-4
  v-row.flex-grow-1(density="compact")
    v-col(cols="6" md="3")
      v-card.dashboard-cards__threads.fill-height(
        variant="tonal"
        :color="activeSection === 'threads' ? 'primary' : undefined"
        :active="false"
        to="/dashboard"
      )
        v-card-text.d-flex.align-center.ga-3.pa-3
          common-icon(name="mdi-forum")
          div
            .text-title-small {{ t('group_cards.threads') }}
            .text-body-small.text-medium-emphasis
              a.dashboard-cards__unread-link.text-decoration-none.underline-on-hover(
                href="/dashboard?unread=1"
                :class="route.query.unread || unreadCounts.total > 0 ? 'text-primary font-weight-medium' : 'text-medium-emphasis'"
                @click.prevent.stop="go('/dashboard?unread=1')"
              ) {{ t('dashboard_cards.unread_count', { count: unreadCounts.total }, unreadCounts.total) }}
              span.mx-1 ·
              a.dashboard-cards__direct-link.text-decoration-none.underline-on-hover(
                href="/dashboard?direct=1"
                :class="route.query.direct || unreadCounts.direct > 0 ? 'text-primary font-weight-medium' : 'text-medium-emphasis'"
                @click.prevent.stop="go('/dashboard?direct=1')"
              ) {{ t('dashboard_cards.direct_count', { count: unreadCounts.direct }, unreadCounts.direct) }}
    v-col(cols="6" md="3")
      v-card.dashboard-cards__polls.fill-height(
        variant="tonal"
        :color="activeSection === 'polls' ? 'primary' : undefined"
        :active="false"
        to="/dashboard/polls"
      )
        v-card-text.d-flex.align-center.ga-3.pa-3
          common-icon(name="mdi-poll")
          div
            .text-title-small {{ t('group_page.polls') }}
            .text-body-small.text-medium-emphasis
              a.dashboard-cards__need-vote-link.text-decoration-none.underline-on-hover(
                href="/dashboard/polls?status=vote"
                :class="pendingPollsCount > 0 || route.query.status === 'vote' ? 'text-primary font-weight-medium' : 'text-medium-emphasis'"
                @click.prevent.stop="go('/dashboard/polls?status=vote')"
              ) {{ t('group_cards.need_vote_count', { count: pendingPollsCount }) }}
              span.mx-1 ·
              a.dashboard-cards__open-polls-link.text-decoration-none.underline-on-hover(
                href="/dashboard/polls?status=active"
                :class="route.query.status === 'active' ? 'text-primary font-weight-medium' : 'text-medium-emphasis'"
                @click.prevent.stop="go('/dashboard/polls?status=active')"
              ) {{ t('group_cards.open_count', { count: openPollsCount }) }}
    v-col(cols="6" md="3")
      v-card.dashboard-cards__people.fill-height(
        variant="tonal"
        :color="activeSection === 'people' ? 'primary' : undefined"
        :active="false"
        to="/dashboard/members"
      )
        v-card-text.d-flex.align-center.ga-3.pa-3
          common-icon(name="mdi-account-group")
          div
            .text-title-small {{ t('dashboard_cards.people') }}
            .text-body-small.text-medium-emphasis {{ t('dashboard_cards.recently_online') }}
    v-col(cols="6" md="3")
      v-card.dashboard-cards__tasks.fill-height(
        variant="tonal"
        :color="activeSection === 'tasks' ? 'primary' : undefined"
        :active="false"
        to="/dashboard/tasks"
      )
        v-card-text.d-flex.align-center.ga-3.pa-3
          common-icon(name="mdi-checkbox-marked-outline")
          div
            .text-title-small {{ t('tasks.tasks') }}
            .text-body-small.text-medium-emphasis {{ t('dashboard_cards.your_tasks') }}
  v-menu
    template(#activator="{ props }")
      v-card.dashboard-cards__more.d-flex.align-center.justify-center.flex-shrink-0(
        v-bind="props"
        variant="tonal"
        :color="overflowActive ? 'primary' : undefined"
        width="56"
        :aria-label="t('action_dock.more')"
      )
        common-icon(name="mdi-dots-horizontal")
    v-list(density="compact")
      v-list-item.dashboard-cards__files(to="/dashboard/files" :active="activeSection === 'files'")
        template(#prepend)
          common-icon.mr-2(name="mdi-file")
        v-list-item-title {{ t('group_page.files') }}
      v-list-item.dashboard-cards__bookmarks(to="/dashboard/bookmarks" :active="activeSection === 'bookmarks'")
        template(#prepend)
          common-icon.mr-2(name="mdi-bookmark-outline")
        v-list-item-title
          span {{ t('bookmarks.bookmarks') }}
          span.text-medium-emphasis(v-if="bookmarksCount")  ({{ bookmarksCount }})
</template>
