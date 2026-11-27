<script setup lang="js">
import { computed, onBeforeUnmount, onMounted, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRoute, useRouter } from 'vue-router';
import { unreadCutoffDate } from '@/shared/helpers/unread_cutoff.mjs';
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import { usePendingPolls } from '@/composables/usePendingPolls';
import { useBookmarks } from '@/composables/useBookmarks';
import { useTasks } from '@/composables/useTasks';
import { usePeopleSummary } from '@/composables/usePeopleSummary';
import { useFilesSummary } from '@/composables/useFilesSummary';

const { t } = useI18n();
const route = useRoute();
const router = useRouter();
const { loadPendingPolls, findPendingPolls } = usePendingPolls();
const { loadBookmarks } = useBookmarks();
const { loadTasks, taskIds } = useTasks();
const { loadPeopleSummary, recentlyOnlineCount } = usePeopleSummary();
const { loadFilesSummary, getFilesCount } = useFilesSummary();

loadPendingPolls();
loadBookmarks();
loadTasks();
loadPeopleSummary();
loadFilesSummary();

const filesCount = computed(() => getFilesCount(null));

const activeSection = computed(() => {
  const path = route?.path || '';
  if (path.startsWith('/dashboard/polls')) { return 'polls'; }
  if (path.startsWith('/dashboard/members') || path.startsWith('/dashboard/people')) { return 'people'; }
  if (path.startsWith('/dashboard/tasks') || path.startsWith('/tasks')) { return 'tasks'; }
  if (path.startsWith('/dashboard/files')) { return 'files'; }
  if (path.startsWith('/dashboard/bookmarks') || path.startsWith('/bookmarks')) { return 'bookmarks'; }
  return 'threads';
});

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
const incompleteTasksCount = computed(() => (
  taskIds.value.length > 0 ? Records.tasks.find(taskIds.value).filter(t => !t.doneAt).length : 0
));
const bookmarksCount = computed(() => Records.bookmarks.find({ userId: Session.userId, discardedAt: null }).length);

const wrapEl = ref(null);
const containerWidth = ref(1024);
let resizeObserver = null;

onMounted(() => {
  if (!wrapEl.value || typeof ResizeObserver === 'undefined') { return; }
  containerWidth.value = wrapEl.value.clientWidth || 1024;
  resizeObserver = new ResizeObserver(entries => {
    containerWidth.value = entries[0]?.contentRect?.width || 1024;
  });
  resizeObserver.observe(wrapEl.value);
});

onBeforeUnmount(() => {
  resizeObserver?.disconnect();
});

function isCollapsed(section) {
  const w = containerWidth.value;
  if (w <= 380) { return true; }
  if (activeSection.value === section) { return false; }
  if (section === 'tasks' || section === 'bookmarks') { return true; }
  if (section === 'files') { return w < 900; }
  if (section === 'people') { return w <= 680; }
  if (section === 'polls') { return w <= 500; }
  return false;
}
</script>

<template lang="pug">
.dashboard-cards-wrap.my-4(ref="wrapEl")
  .dashboard-cards.d-flex.flex-nowrap.align-stretch.ga-2
    v-tooltip(location="bottom" :text="t('group_cards.threads')" :disabled="!isCollapsed('threads')")
      template(#activator="{ props }")
        v-card.dashboard-cards__card.dashboard-cards__threads(
          v-bind="props"
          variant="tonal"
          :color="activeSection === 'threads' ? 'primary' : undefined"
          :class="{ 'dashboard-cards__card--active': activeSection === 'threads' }"
          :active="false"
          to="/dashboard"
          :aria-label="t('group_cards.threads')"
        )
          .dashboard-cards__inner
            v-badge.dashboard-cards__badge(
              :model-value="unreadCounts.total > 0"
              :content="unreadCounts.total"
            )
              common-icon(name="mdi-forum")
            .dashboard-cards__label
              .text-title-small.text-truncate {{ t('group_cards.threads') }}
              .text-body-small.text-medium-emphasis.text-truncate
                a.dashboard-cards__unread-link.text-decoration-none.underline-on-hover.text-medium-emphasis(
                  href="/dashboard?unread=1"
                  @click.prevent.stop="go('/dashboard?unread=1')"
                ) {{ t('dashboard_cards.unread_count', { count: unreadCounts.total }, unreadCounts.total) }}
                template(v-if="unreadCounts.direct > 0")
                  span.mx-1 ·
                  a.dashboard-cards__direct-link.text-decoration-none.underline-on-hover.text-medium-emphasis(
                    href="/dashboard?direct=1&unread=1"
                    @click.prevent.stop="go('/dashboard?direct=1&unread=1')"
                  ) {{ t('dashboard_cards.direct_count', { count: unreadCounts.direct }, unreadCounts.direct) }}

    v-tooltip(location="bottom" :text="t('group_page.polls')" :disabled="!isCollapsed('polls')")
      template(#activator="{ props }")
        v-card.dashboard-cards__card.dashboard-cards__polls(
          v-bind="props"
          variant="tonal"
          :color="activeSection === 'polls' ? 'primary' : undefined"
          :class="{ 'dashboard-cards__card--active': activeSection === 'polls' }"
          :active="false"
          to="/dashboard/polls"
          :aria-label="t('group_page.polls')"
        )
          .dashboard-cards__inner
            v-badge.dashboard-cards__badge(
              :model-value="pendingPollsCount > 0"
              :content="pendingPollsCount"
            )
              common-icon(name="mdi-poll")
            .dashboard-cards__label
              .text-title-small.text-truncate {{ t('group_page.polls') }}
              .text-body-small.text-medium-emphasis.text-truncate
                a.dashboard-cards__need-vote-link.text-decoration-none.underline-on-hover.text-medium-emphasis(
                  href="/dashboard/polls?status=vote"
                  @click.prevent.stop="go('/dashboard/polls?status=vote')"
                ) {{ t('group_cards.need_vote_count', { count: pendingPollsCount }, pendingPollsCount) }}
                span.mx-1 ·
                a.dashboard-cards__open-polls-link.text-decoration-none.underline-on-hover.text-medium-emphasis(
                  href="/dashboard/polls?status=active"
                  @click.prevent.stop="go('/dashboard/polls?status=active')"
                ) {{ t('group_cards.open_count', { count: openPollsCount }) }}

    v-tooltip(location="bottom" :text="t('dashboard_cards.people')" :disabled="!isCollapsed('people')")
      template(#activator="{ props }")
        v-card.dashboard-cards__card.dashboard-cards__people(
          v-bind="props"
          variant="tonal"
          :color="activeSection === 'people' ? 'primary' : undefined"
          :class="{ 'dashboard-cards__card--active': activeSection === 'people' }"
          :active="false"
          to="/dashboard/members"
          :aria-label="t('dashboard_cards.people')"
        )
          .dashboard-cards__inner
            v-badge.dashboard-cards__badge(
              :model-value="Boolean(recentlyOnlineCount && recentlyOnlineCount > 0)"
              :content="recentlyOnlineCount"
            )
              common-icon(name="mdi-account-group")
            .dashboard-cards__label
              .text-title-small.text-truncate {{ t('dashboard_cards.people') }}
              .text-body-small.text-medium-emphasis.text-truncate
                template(v-if="recentlyOnlineCount !== null") {{ t('dashboard_cards.recently_online_count', { count: recentlyOnlineCount }, recentlyOnlineCount) }}
                template(v-else) {{ t('dashboard_cards.recently_online') }}

    v-tooltip(location="bottom" :text="t('group_page.files')" :disabled="!isCollapsed('files')")
      template(#activator="{ props }")
        v-card.dashboard-cards__card.dashboard-cards__files(
          v-bind="props"
          variant="tonal"
          :color="activeSection === 'files' ? 'primary' : undefined"
          :class="{ 'dashboard-cards__card--active': activeSection === 'files' }"
          :active="false"
          to="/dashboard/files"
          :aria-label="t('group_page.files')"
        )
          .dashboard-cards__inner
            common-icon(name="mdi-file")
            .dashboard-cards__label
              .text-title-small.text-truncate {{ t('group_page.files') }}
              .text-body-small.text-medium-emphasis.text-truncate(v-if="filesCount !== null") {{ t('group_cards.files_count', { count: filesCount }, filesCount) }}

    v-tooltip(location="bottom" :text="t('tasks.tasks')" :disabled="!isCollapsed('tasks')")
      template(#activator="{ props }")
        v-card.dashboard-cards__card.dashboard-cards__tasks.dashboard-cards__tile-default(
          v-bind="props"
          variant="tonal"
          :color="activeSection === 'tasks' ? 'primary' : undefined"
          :class="{ 'dashboard-cards__card--active': activeSection === 'tasks' }"
          :active="false"
          to="/dashboard/tasks"
          :aria-label="t('tasks.tasks')"
        )
          .dashboard-cards__inner
            v-badge.dashboard-cards__badge(
              :model-value="incompleteTasksCount > 0"
              :content="incompleteTasksCount"
            )
              common-icon(name="mdi-checkbox-marked-outline")
            .dashboard-cards__label
              .text-title-small.text-truncate {{ t('tasks.tasks') }}
              .text-body-small.text-medium-emphasis.text-truncate
                a.dashboard-cards__todo-link.text-decoration-none.underline-on-hover.text-medium-emphasis(
                  href="/dashboard/tasks?status=todo"
                  @click.prevent.stop="go('/dashboard/tasks?status=todo')"
                ) {{ t('dashboard_cards.tasks_todo_count', { count: incompleteTasksCount }, incompleteTasksCount) }}

    v-tooltip(location="bottom" :text="t('bookmarks.bookmarks')" :disabled="!isCollapsed('bookmarks')")
      template(#activator="{ props }")
        v-card.dashboard-cards__card.dashboard-cards__bookmarks.dashboard-cards__tile-default(
          v-bind="props"
          variant="tonal"
          :color="activeSection === 'bookmarks' ? 'primary' : undefined"
          :class="{ 'dashboard-cards__card--active': activeSection === 'bookmarks' }"
          :active="false"
          to="/dashboard/bookmarks"
          :aria-label="t('bookmarks.bookmarks')"
        )
          .dashboard-cards__inner
            v-badge.dashboard-cards__badge(
              :model-value="bookmarksCount > 0"
              :content="bookmarksCount"
            )
              common-icon(name="mdi-bookmark-outline")
            .dashboard-cards__label
              .text-title-small.text-truncate {{ t('bookmarks.bookmarks') }}
              .text-body-small.text-medium-emphasis.text-truncate {{ t('dashboard_cards.bookmarks_saved_count', { count: bookmarksCount }, bookmarksCount) }}
</template>

<style scoped>
.dashboard-cards-wrap {
  container-type: inline-size;
}

.dashboard-cards__card {
  flex: 1 1 0;
  min-width: 0;
  min-height: 58px;
  display: flex;
  align-items: center;
}

.dashboard-cards__inner {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 12px;
  width: 100%;
  min-width: 0;
}

.dashboard-cards__label {
  min-width: 0;
  flex: 1 1 auto;
}

/* Badges only show when a card is collapsed to a tile */
.dashboard-cards__badge :deep(.v-badge__badge) {
  display: none;
  background-color: rgb(var(--v-theme-surface));
  color: rgba(var(--v-theme-on-surface), 0.72);
  border: 1px solid rgba(var(--v-theme-on-surface), 0.22);
}

/* Files & Bookmarks start as compact icon+badge tiles */
.dashboard-cards__tile-default {
  flex: 0 0 58px;
}
.dashboard-cards__tile-default .dashboard-cards__inner {
  justify-content: center;
  padding: 0;
}
.dashboard-cards__tile-default .dashboard-cards__label {
  display: none;
}
.dashboard-cards__tile-default .dashboard-cards__badge :deep(.v-badge__badge) {
  display: inline-flex;
}

/* Collapse Files to tile below 900px */
@container (max-width: 899px) {
  .dashboard-cards__files {
    flex: 0 0 58px;
  }
  .dashboard-cards__files .dashboard-cards__inner {
    justify-content: center;
    padding: 0;
  }
  .dashboard-cards__files .dashboard-cards__label {
    display: none;
  }
}

/* Collapse People to tile below 680px */
@container (max-width: 680px) {
  .dashboard-cards__people {
    flex: 0 0 58px;
  }
  .dashboard-cards__people .dashboard-cards__inner {
    justify-content: center;
    padding: 0;
  }
  .dashboard-cards__people .dashboard-cards__label {
    display: none;
  }
  .dashboard-cards__people .dashboard-cards__badge :deep(.v-badge__badge) {
    display: inline-flex;
  }
}

/* Collapse Polls to tile below 500px */
@container (max-width: 500px) {
  .dashboard-cards__polls,
  .dashboard-cards__people,
  .dashboard-cards__tasks,
  .dashboard-cards__files,
  .dashboard-cards__bookmarks {
    flex: 0 0 48px;
  }
  .dashboard-cards__polls .dashboard-cards__inner {
    justify-content: center;
    padding: 0;
  }
  .dashboard-cards__polls .dashboard-cards__label {
    display: none;
  }
  .dashboard-cards__polls .dashboard-cards__badge :deep(.v-badge__badge) {
    display: inline-flex;
  }
}

/* Active tab always expands to full card view */
@container (min-width: 381px) {
  .dashboard-cards__card.dashboard-cards__card--active {
    flex: 1 1 0;
  }
  .dashboard-cards__card.dashboard-cards__card--active .dashboard-cards__inner {
    justify-content: flex-start;
    padding: 10px 12px;
  }
  .dashboard-cards__card.dashboard-cards__card--active .dashboard-cards__label {
    display: block;
  }
  .dashboard-cards__card.dashboard-cards__card--active .dashboard-cards__badge :deep(.v-badge__badge) {
    display: none;
  }
}

/* Below 380px: all 6 equal icon+badge tiles in one row */
@container (max-width: 380px) {
  .dashboard-cards__card {
    flex: 1 1 0;
  }
  .dashboard-cards__threads .dashboard-cards__inner {
    justify-content: center;
    padding: 0;
  }
  .dashboard-cards__threads .dashboard-cards__label {
    display: none;
  }
  .dashboard-cards__badge :deep(.v-badge__badge) {
    display: inline-flex;
  }
}
</style>
