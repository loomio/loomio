<script setup lang="js">
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRoute, useRouter } from 'vue-router';
import EventBus from '@/shared/services/event_bus';
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import GroupAbility from '@/shared/abilities/group_ability';
import { unreadCutoffDate } from '@/shared/helpers/unread_cutoff.mjs';
import { useBookmarks } from '@/composables/useBookmarks';
import { useTasks } from '@/composables/useTasks';

const { group } = defineProps({ group: Object });
const { t } = useI18n();
const route = useRoute();
const router = useRouter();
const isSignedIn = computed(() => Session.isSignedIn());

const { loadBookmarks } = useBookmarks();
const { loadTasks, taskIds } = useTasks();

if (isSignedIn.value && Records.bookmarks?.fetch) { loadBookmarks(); }
if (isSignedIn.value && Records.tasks?.remote?.fetch) { loadTasks(); }

const canAddMembers = computed(() => GroupAbility.canAddMembers(group));
const showInviteLink = computed(() => canAddMembers.value && (group.membershipsCount || 0) < 3);

const basePath = computed(() => (group.handle ? `/${group.handle}` : `/g/${group.key}`));
const threadsRoute = computed(() => basePath.value);
const membersRoute = computed(() => `${basePath.value}/members`);
const pollsRoute = computed(() => `${basePath.value}/polls`);
const tasksRoute = computed(() => `${basePath.value}/tasks`);
const filesRoute = computed(() => `${basePath.value}/files`);
const bookmarksRoute = computed(() => `${basePath.value}/bookmarks`);

const activeSection = computed(() => {
  const segments = (route?.path || '').split('/').filter(Boolean);
  if (segments.includes('members')) { return 'members'; }
  if (segments.includes('polls')) { return 'polls'; }
  if (segments.includes('tasks')) { return 'tasks'; }
  if (segments.includes('files')) { return 'files'; }
  if (segments.includes('bookmarks')) { return 'bookmarks'; }
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

function groupIdForTask(task) {
  const record = task?.record?.();
  if (!record) { return null; }
  if (record.isA?.('group')) { return record.id; }
  const topic = typeof record.topic === 'function' ? record.topic() : (record.topicId ? Records.topics?.find?.(record.topicId) : null);
  return topic?.groupId || record.groupId || null;
}

const incompleteTasksCount = computed(() => {
  if (!isSignedIn.value || !Records.tasks?.find || taskIds.value.length === 0) { return 0; }
  return Records.tasks.find(taskIds.value).filter(task => !task.doneAt && groupIdForTask(task) === group.id).length;
});

const bookmarksCount = computed(() => {
  if (!isSignedIn.value || !Records.bookmarks?.find) { return 0; }
  return Records.bookmarks.find({ userId: Session.userId, discardedAt: null })
    .filter(b => b.groupId === group.id).length;
});

function go(path) {
  router.push(path);
}

function invite() {
  const allowed = Session.user().emailInvitationsAllowed() || group.emailInvitationsAllowed();
  const component = allowed ? 'GroupInvitationForm' : 'GroupShareableLinkForm';
  EventBus.$emit('openModal', { component, props: { group } });
}
</script>

<template lang="pug">
.group-cards-wrap.my-4
  .group-cards.d-flex.flex-nowrap.align-stretch.ga-2
    v-tooltip(location="bottom" :text="t('group_cards.threads')")
      template(#activator="{ props }")
        v-card.group-cards__card.group-cards__threads.group-page-discussions-tab(
          v-bind="props"
          variant="tonal"
          :color="activeSection === 'threads' ? 'primary' : undefined"
          :class="{ 'group-cards__card--active': activeSection === 'threads' }"
          :active="false"
          :to="threadsRoute"
          :aria-label="t('group_cards.threads')"
        )
          .group-cards__inner
            v-badge.group-cards__badge(
              :model-value="unreadThreadsCount > 0"
              :content="unreadThreadsCount"
            )
              common-icon(name="mdi-forum")
            .group-cards__label
              .text-title-small.text-truncate {{ t('group_cards.threads') }}
              .text-body-small.text-medium-emphasis.text-truncate
                a.group-cards__recent-link.text-decoration-none.underline-on-hover.text-medium-emphasis(
                  :href="threadsRoute"
                  @click.prevent.stop="go(threadsRoute)"
                ) {{ t('group_cards.recent_count', { count: recentThreadsCount }) }}
                span.mx-1 ·
                a.group-cards__unread-link.text-decoration-none.underline-on-hover.text-medium-emphasis(
                  :href="threadsRoute + '?unread=1'"
                  @click.prevent.stop="go(threadsRoute + '?unread=1')"
                ) {{ t('dashboard_cards.unread_count', { count: unreadThreadsCount }) }}

    v-tooltip(location="bottom" :text="t('group_page.polls')")
      template(#activator="{ props }")
        v-card.group-cards__card.group-cards__polls.group-page-polls-tab(
          v-bind="props"
          variant="tonal"
          :color="activeSection === 'polls' ? 'primary' : undefined"
          :class="{ 'group-cards__card--active': activeSection === 'polls' }"
          :active="false"
          :to="pollsRoute"
          :aria-label="t('group_page.polls')"
        )
          .group-cards__inner
            v-badge.group-cards__badge(
              :model-value="votesNeededCount > 0"
              :content="votesNeededCount"
            )
              common-icon(name="mdi-poll")
            .group-cards__label
              .text-title-small.text-truncate {{ t('group_page.polls') }}
              .text-body-small.text-medium-emphasis.text-truncate
                a.group-cards__need-vote-link.text-decoration-none.underline-on-hover.text-medium-emphasis(
                  :href="pollsRoute + '?status=vote'"
                  @click.prevent.stop="go(pollsRoute + '?status=vote')"
                ) {{ t('group_cards.need_vote_count', { count: votesNeededCount }) }}
                span.mx-1 ·
                a.group-cards__open-polls-link.text-decoration-none.underline-on-hover.text-medium-emphasis(
                  :href="pollsRoute + '?status=active'"
                  @click.prevent.stop="go(pollsRoute + '?status=active')"
                ) {{ t('group_cards.open_count', { count: openPollsCount }) }}

    v-tooltip(location="bottom" :text="t('group_page.members')")
      template(#activator="{ props }")
        v-card.group-cards__card.group-cards__members.group-page-members-tab(
          v-bind="props"
          variant="tonal"
          :color="activeSection === 'members' ? 'primary' : undefined"
          :class="{ 'group-cards__card--active': activeSection === 'members' }"
          :active="false"
          :to="membersRoute"
          :aria-label="t('group_page.members')"
        )
          .group-cards__inner
            common-icon(name="mdi-account-group")
            .group-cards__label
              .text-title-small.text-truncate {{ t('group_page.members') }}
              .text-body-small.text-medium-emphasis.text-truncate
                span(v-if="membersSubtitle") {{ membersSubtitle }}
                template(v-if="showInviteLink")
                  span.mx-1(v-if="membersSubtitle") ·
                  a.group-cards__invite.text-primary.font-weight-medium.text-decoration-none.underline-on-hover(
                    href="#"
                    @click.prevent.stop="invite"
                  ) {{ t('group_page.invite_people') }}

    v-tooltip(v-if="isSignedIn" location="bottom" :text="t('tasks.tasks')")
      template(#activator="{ props }")
        v-card.group-cards__card.group-cards__tasks(
          v-bind="props"
          variant="tonal"
          :color="activeSection === 'tasks' ? 'primary' : undefined"
          :class="{ 'group-cards__card--active': activeSection === 'tasks' }"
          :active="false"
          :to="tasksRoute"
          :aria-label="t('tasks.tasks')"
        )
          .group-cards__inner
            v-badge.group-cards__badge(
              :model-value="incompleteTasksCount > 0"
              :content="incompleteTasksCount"
            )
              common-icon(name="mdi-checkbox-marked-outline")
            .group-cards__label
              .text-title-small.text-truncate {{ t('tasks.tasks') }}
              .text-body-small.text-medium-emphasis.text-truncate
                a.group-cards__todo-link.text-decoration-none.underline-on-hover.text-medium-emphasis(
                  :href="tasksRoute + '?status=todo'"
                  @click.prevent.stop="go(tasksRoute + '?status=todo')"
                ) {{ t('dashboard_cards.tasks_todo_count', { count: incompleteTasksCount }, incompleteTasksCount) }}

    v-tooltip(location="bottom" :text="t('group_page.files')")
      template(#activator="{ props }")
        v-card.group-cards__card.group-cards__files.group-page-files-tab.group-cards__tile-default(
          v-bind="props"
          variant="tonal"
          :color="activeSection === 'files' ? 'primary' : undefined"
          :class="{ 'group-cards__card--active': activeSection === 'files' }"
          :active="false"
          :to="filesRoute"
          :aria-label="t('group_page.files')"
        )
          .group-cards__inner
            common-icon(name="mdi-file")
            .group-cards__label
              .text-title-small.text-truncate {{ t('group_page.files') }}
              .text-body-small.text-medium-emphasis.text-truncate {{ t('group_cards.browse_files') }}

    v-tooltip(v-if="isSignedIn" location="bottom" :text="t('bookmarks.bookmarks')")
      template(#activator="{ props }")
        v-card.group-cards__card.group-cards__bookmarks.group-cards__tile-default(
          v-bind="props"
          variant="tonal"
          :color="activeSection === 'bookmarks' ? 'primary' : undefined"
          :class="{ 'group-cards__card--active': activeSection === 'bookmarks' }"
          :active="false"
          :to="bookmarksRoute"
          :aria-label="t('bookmarks.bookmarks')"
        )
          .group-cards__inner
            v-badge.group-cards__badge(
              :model-value="bookmarksCount > 0"
              :content="bookmarksCount"
            )
              common-icon(name="mdi-bookmark-outline")
            .group-cards__label
              .text-title-small.text-truncate {{ t('bookmarks.bookmarks') }}
              .text-body-small.text-medium-emphasis.text-truncate {{ t('dashboard_cards.bookmarks_saved_count', { count: bookmarksCount }, bookmarksCount) }}
</template>

<style scoped>
.group-cards-wrap {
  container-type: inline-size;
}

.group-cards__card {
  flex: 1 1 0;
  min-width: 0;
  min-height: 58px;
  display: flex;
  align-items: center;
}

.group-cards__inner {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 12px;
  width: 100%;
  min-width: 0;
}

.group-cards__label {
  min-width: 0;
  flex: 1 1 auto;
}

.min-width-0 {
  min-width: 0;
}

/* Badges only show when a card is collapsed to a tile */
.group-cards__badge :deep(.v-badge__badge) {
  display: none;
  background-color: rgb(var(--v-theme-surface));
  color: rgba(var(--v-theme-on-surface), 0.72);
  border: 1px solid rgba(var(--v-theme-on-surface), 0.22);
}

/* Files & Bookmarks start as compact icon+badge tiles */
.group-cards__tile-default {
  flex: 0 0 58px;
}
.group-cards__tile-default .group-cards__inner {
  justify-content: center;
  padding: 0;
}
.group-cards__tile-default .group-cards__label {
  display: none;
}
.group-cards__tile-default .group-cards__badge :deep(.v-badge__badge) {
  display: inline-flex;
}

/* Collapse Tasks to tile below 900px */
@container (max-width: 899px) {
  .group-cards__tasks {
    flex: 0 0 58px;
  }
  .group-cards__tasks .group-cards__inner {
    justify-content: center;
    padding: 0;
  }
  .group-cards__tasks .group-cards__label {
    display: none;
  }
  .group-cards__tasks .group-cards__badge :deep(.v-badge__badge) {
    display: inline-flex;
  }
}

/* Collapse Members to tile below 680px */
@container (max-width: 680px) {
  .group-cards__members {
    flex: 0 0 58px;
  }
  .group-cards__members .group-cards__inner {
    justify-content: center;
    padding: 0;
  }
  .group-cards__members .group-cards__label {
    display: none;
  }
}

/* Collapse Polls to tile below 500px */
@container (max-width: 500px) {
  .group-cards__polls,
  .group-cards__members,
  .group-cards__tasks,
  .group-cards__files,
  .group-cards__bookmarks {
    flex: 0 0 48px;
  }
  .group-cards__polls .group-cards__inner {
    justify-content: center;
    padding: 0;
  }
  .group-cards__polls .group-cards__label {
    display: none;
  }
  .group-cards__polls .group-cards__badge :deep(.v-badge__badge) {
    display: inline-flex;
  }
}

/* Active tab always expands to full card view */
@container (min-width: 381px) {
  .group-cards__card.group-cards__card--active {
    flex: 1 1 0;
  }
  .group-cards__card.group-cards__card--active .group-cards__inner {
    justify-content: flex-start;
    padding: 10px 12px;
  }
  .group-cards__card.group-cards__card--active .group-cards__label {
    display: block;
  }
  .group-cards__card.group-cards__card--active .group-cards__badge :deep(.v-badge__badge) {
    display: none;
  }
}

/* Below 380px: all equal icon+badge tiles in one row */
@container (max-width: 380px) {
  .group-cards__card {
    flex: 1 1 0;
  }
  .group-cards__threads .group-cards__inner {
    justify-content: center;
    padding: 0;
  }
  .group-cards__threads .group-cards__label {
    display: none;
  }
  .group-cards__badge :deep(.v-badge__badge) {
    display: inline-flex;
  }
}
</style>
