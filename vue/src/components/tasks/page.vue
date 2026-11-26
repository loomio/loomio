<script setup lang="js">
import { ref, computed, watch, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { format, isSameYear, startOfDay, addDays } from 'date-fns';
import { debounce, groupBy } from 'lodash-es';
import { mdiMagnify } from '@mdi/js';
import { dateLocale } from '@/i18n';
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import Flash from '@/shared/services/flash';
import EventBus from '@/shared/services/event_bus';
import LmoUrlService from '@/shared/services/lmo_url_service';
import { taskRecordTitle } from '@/shared/helpers/task_record_title.mjs';
import { manualUrl } from '@/shared/helpers/manual_url';
import { useTasks } from '@/composables/useTasks';
import TagsFilterMenu from '@/components/tags/filter_menu.vue';
import SubgroupsFilterMenu from '@/components/group/subgroups_filter_menu.vue';

const { embedded } = defineProps({
  embedded: { type: Boolean, default: false }
});

const route = useRoute();
const router = useRouter();
const { t, locale } = useI18n();
const { loadTasks, taskIds } = useTasks();

const group = computed(() => (
  route.params.key ? Records.groups.fuzzyFind(route.params.key) : null
));

const loading = ref(true);
const groupTaskIds = ref([]);
const memberMenuOpen = ref(false);
const memberSearch = ref('');
const memberOptions = ref([]);
const loadingMembers = ref(false);
const selectedAssignee = ref(null);

const statusFilter = computed({
  get: () => (['todo', 'done', 'all'].includes(route.query?.status) ? route.query.status : 'todo'),
  set: (val) => {
    const query = { ...route.query };
    if (val === 'todo') { delete query.status; } else { query.status = val; }
    router.replace({ query });
  }
});
const dueFilter = computed({
  get: () => (['overdue', 'next_7_days', 'later', 'none'].includes(route.query?.due) ? route.query.due : null),
  set: (val) => {
    const query = { ...route.query };
    if (!val) { delete query.due; } else { query.due = val; }
    router.replace({ query });
  }
});
const assigneeId = computed({
  get: () => {
    if (!group.value) { return null; }
    const raw = route.query?.user_id;
    if (!raw) { return null; }
    if (raw === 'me') { return Session.userId; }
    const num = parseInt(raw, 10);
    return Number.isFinite(num) ? num : null;
  },
  set: (val) => {
    const query = { ...route.query };
    if (!val) { delete query.user_id; } else { query.user_id = String(val); }
    router.replace({ query });
  }
});
const subgroupsFilter = computed({
  get: () => (group.value && group.value.subgroupsCount > 0 && ['mine', 'all'].includes(route.query?.subgroups) ? route.query.subgroups : null),
  set: (val) => {
    const query = { ...route.query };
    if (!val) { delete query.subgroups; } else { query.subgroups = val; }
    router.replace({ query });
  }
});
const selectedTag = ref(null);
const searchQuery = ref('');
const recentlyToggledIds = ref(new Set());

watch([statusFilter, dueFilter, assigneeId, subgroupsFilter, selectedTag, searchQuery, () => group.value?.id], () => {
  recentlyToggledIds.value = new Set();
});

function fetchCurrentTasks() {
  if (group.value) {
    const params = { group_id: group.value.id };
    if (assigneeId.value) { params.user_id = assigneeId.value; }
    if (subgroupsFilter.value) { params.subgroups = subgroupsFilter.value; }
    loading.value = groupTaskIds.value.length === 0;
    Records.tasks.fetch({ params }).then(data => {
      groupTaskIds.value = (data?.tasks || []).map(t => t.id);
    }).finally(() => {
      loading.value = false;
    });
  } else {
    loading.value = taskIds.value.length === 0;
    loadTasks().finally(() => {
      loading.value = false;
    });
  }
}

const fetchGroupMembers = debounce((q = '') => {
  if (!group.value) { return; }
  loadingMembers.value = true;
  Records.memberships.fetch({
    params: {
      group_id: group.value.id,
      q: q.trim() || undefined,
      per: 15
    }
  }).then(data => {
    memberOptions.value = (data?.users || [])
      .filter(u => u.id !== Session.userId)
      .map(u => Records.users.find(u.id))
      .filter(Boolean);
  }).finally(() => {
    loadingMembers.value = false;
  });
}, 250);

watch(memberMenuOpen, isOpen => {
  if (isOpen && group.value) {
    fetchGroupMembers(memberSearch.value);
  } else if (!isOpen) {
    memberSearch.value = '';
  }
});

watch(memberSearch, val => {
  if (memberMenuOpen.value) { fetchGroupMembers(val || ''); }
});

watch([() => group.value?.id, assigneeId, subgroupsFilter], fetchCurrentTasks);

onMounted(() => {
  EventBus.$emit('content-title-visible', false);
  fetchCurrentTasks();
});

function selectAssignee(user) {
  selectedAssignee.value = user || null;
  assigneeId.value = user ? user.id : null;
  memberMenuOpen.value = false;
}

const assigneeLabel = computed(() => {
  if (!assigneeId.value) { return t('tasks.assigned_anyone'); }
  if (assigneeId.value === Session.userId) { return t('tasks.assigned_me'); }
  if (selectedAssignee.value?.id === assigneeId.value) { return selectedAssignee.value.name; }
  const cached = Records.users.find(assigneeId.value);
  return cached?.name || t('tasks.assigned_me');
});

function topicForRecord(record) {
  if (!record) { return null; }
  if (typeof record.topic === 'function') { return record.topic(); }
  if (record.topicId) { return Records.topics.find(record.topicId); }
  return null;
}

function groupForRecord(record) {
  if (!record) { return null; }
  if (record.isA?.('group')) { return record; }
  const topic = topicForRecord(record);
  if (topic && typeof topic.group === 'function') { return topic.group(); }
  if (typeof record.group === 'function') { return record.group(); }
  return null;
}

function tagsForRecord(record) {
  const topic = topicForRecord(record);
  return topic?.tags || [];
}

function taskUrlFor(record) {
  if (!record) { return '/dashboard'; }
  const base = LmoUrlService.route({ model: record });
  return record.isA?.('discussion') ? `${base}/0` : base;
}

const allTasks = computed(() => {
  const ids = group.value ? groupTaskIds.value : taskIds.value;
  if (ids.length === 0) { return []; }
  return Records.tasks.find(ids).filter(task => task.record() != null);
});

function parseDueDate(dueOn) {
  if (!dueOn) { return null; }
  const date = dueOn instanceof Date ? dueOn : new Date(dueOn);
  return Number.isNaN(date.getTime()) ? null : date;
}

function isOverdue(task) {
  if (task.doneAt || !task.dueOn) { return false; }
  const date = parseDueDate(task.dueOn);
  return Boolean(date && startOfDay(date) < startOfDay(new Date()));
}

const filteredTasks = computed(() => {
  const q = searchQuery.value.trim().toLowerCase();
  const today = startOfDay(new Date());
  const in7Days = addDays(today, 7);

  return allTasks.value.filter(task => {
    const keepVisible = recentlyToggledIds.value.has(task.id);
    if (!keepVisible && statusFilter.value === 'todo' && task.doneAt) { return false; }
    if (!keepVisible && statusFilter.value === 'done' && !task.doneAt) { return false; }

    if (dueFilter.value) {
      const due = parseDueDate(task.dueOn);
      if (dueFilter.value === 'none' && due) { return false; }
      if (dueFilter.value === 'overdue' && (!due || startOfDay(due) >= today)) { return false; }
      if (dueFilter.value === 'next_7_days' && (!due || startOfDay(due) < today || startOfDay(due) > in7Days)) { return false; }
      if (dueFilter.value === 'later' && (!due || startOfDay(due) <= in7Days)) { return false; }
    }

    const record = task.record();
    if (selectedTag.value && !tagsForRecord(record).includes(selectedTag.value)) {
      return false;
    }

    if (q) {
      const title = (taskRecordTitle(record) || '').toLowerCase();
      const groupName = (groupForRecord(record)?.name || '').toLowerCase();
      const name = (task.name || '').toLowerCase();
      if (!name.includes(q) && !title.includes(q) && !groupName.includes(q)) {
        return false;
      }
    }

    return true;
  });
});

const groupedEntries = computed(() => {
  const grouped = groupBy(filteredTasks.value, task => `${task.recordType}:${task.recordId}`);
  return Object.entries(grouped).map(([key, tasks]) => {
    const record = tasks[0].record();
    return {
      key,
      record,
      title: taskRecordTitle(record),
      url: taskUrlFor(record),
      group: groupForRecord(record),
      tasks
    };
  });
});

const statusLabel = computed(() => {
  if (statusFilter.value === 'done') { return t('tasks.status_done'); }
  if (statusFilter.value === 'all') { return t('discussions_panel.all'); }
  return t('tasks.status_todo');
});

const dueLabel = computed(() => {
  if (dueFilter.value === 'overdue') { return t('tasks.due_overdue'); }
  if (dueFilter.value === 'next_7_days') { return t('tasks.due_next_7_days'); }
  if (dueFilter.value === 'later') { return t('tasks.due_later'); }
  if (dueFilter.value === 'none') { return t('tasks.due_none'); }
  return t('tasks.due_any');
});

const hasActiveFilters = computed(() => (
  statusFilter.value !== 'todo' || Boolean(dueFilter.value) || Boolean(assigneeId.value) || Boolean(selectedTag.value) || Boolean(searchQuery.value.trim())
));

function formatDueDate(dueOn) {
  if (!dueOn) { return ''; }
  const date = dueOn instanceof Date ? dueOn : new Date(dueOn);
  if (Number.isNaN(date.getTime())) { return String(dueOn); }
  const pattern = isSameYear(date, new Date()) ? 'MMM d' : 'MMM d, yyyy';
  return format(date, pattern, { locale: dateLocale });
}

function toggleDone(task) {
  const next = new Set(recentlyToggledIds.value);
  next.add(task.id);
  recentlyToggledIds.value = next;
  return task.toggleDone().catch(error => Flash.serverError(error));
}
</script>

<template lang="pug">
component(:is="embedded ? 'div' : 'v-main'")
  component(:is="embedded ? 'div' : 'v-container'" :class="embedded ? 'tasks-page pt-2' : 'dashboard-page max-width-1024 px-2 px-sm-4'")
    template(v-if="!embedded")
      h1.text-headline-large.my-4(tabindex="-1") {{ t('dashboard_cards.all_groups') }}
      dashboard-cards

    .d-flex.align-center.flex-wrap.ga-2.pt-4.pb-3
      subgroups-filter-menu(v-if="group" :group="group" :selected="subgroupsFilter" @select="subgroupsFilter = $event")
      v-menu
        template(#activator="{ props }")
          v-btn.tasks-page__status-filter.text-medium-emphasis(v-bind="props" variant="tonal")
            span {{ statusLabel }}
            common-icon(name="mdi-menu-down")
        v-list(density="compact")
          v-list-item(:active="statusFilter === 'todo'" @click="statusFilter = 'todo'")
            v-list-item-title {{ t('tasks.status_todo') }}
          v-list-item(:active="statusFilter === 'done'" @click="statusFilter = 'done'")
            v-list-item-title {{ t('tasks.status_done') }}
          v-list-item(:active="statusFilter === 'all'" @click="statusFilter = 'all'")
            v-list-item-title {{ t('discussions_panel.all') }}

      v-menu
        template(#activator="{ props }")
          v-btn.tasks-page__due-filter(
            v-bind="props"
            variant="tonal"
            :color="dueFilter ? 'primary' : undefined"
            :class="{ 'text-medium-emphasis': !dueFilter }"
          )
            span {{ dueLabel }}
            common-icon(name="mdi-menu-down" color="currentColor")
        v-list(density="compact")
          v-list-item(:active="!dueFilter" @click="dueFilter = null")
            v-list-item-title {{ t('tasks.due_any') }}
          v-list-item(:active="dueFilter === 'overdue'" @click="dueFilter = 'overdue'")
            v-list-item-title {{ t('tasks.due_overdue') }}
          v-list-item(:active="dueFilter === 'next_7_days'" @click="dueFilter = 'next_7_days'")
            v-list-item-title {{ t('tasks.due_next_7_days') }}
          v-list-item(:active="dueFilter === 'later'" @click="dueFilter = 'later'")
            v-list-item-title {{ t('tasks.due_later') }}
          v-list-item(:active="dueFilter === 'none'" @click="dueFilter = 'none'")
            v-list-item-title {{ t('tasks.due_none') }}

      v-menu(v-if="group" v-model="memberMenuOpen" :close-on-content-click="false")
        template(#activator="{ props }")
          v-btn.tasks-page__assignee-filter(
            v-bind="props"
            variant="tonal"
            :color="assigneeId ? 'primary' : undefined"
            :class="{ 'text-medium-emphasis': !assigneeId }"
          )
            span {{ assigneeLabel }}
            common-icon(name="mdi-menu-down" color="currentColor")
        v-card(min-width="240" max-width="320")
          .pa-2
            v-text-field(
              v-model="memberSearch"
              :placeholder="t('tasks.search_members')"
              :prepend-inner-icon="mdiMagnify"
              :loading="loadingMembers"
              density="compact"
              variant="outlined"
              hide-details
              clearable
            )
          v-list(density="compact" max-height="50vh")
            v-list-item(:active="!assigneeId" @click="selectAssignee(null)")
              v-list-item-title {{ t('tasks.assigned_anyone') }}
            v-list-item(:active="assigneeId === Session.userId" @click="selectAssignee({ id: Session.userId, name: t('tasks.assigned_me') })")
              v-list-item-title {{ t('tasks.assigned_me') }}
            template(v-if="memberOptions.length > 0")
              v-divider.my-1
              v-list-item(
                v-for="member in memberOptions"
                :key="member.id"
                slim
                :active="assigneeId === member.id"
                @click="selectAssignee(member)"
              )
                template(#prepend)
                  user-avatar.mr-2(:user="member" :size="24" no-link)
                v-list-item-title {{ member.name }}

      tags-filter-menu(:group="group" :selected-tag="selectedTag" @select="selectedTag = $event")

      v-spacer
      v-text-field.tasks-page__search(
        v-model="searchQuery"
        :prepend-inner-icon="mdiMagnify"
        :placeholder="t('tasks.search_tasks')"
        variant="outlined"
        density="compact"
        clearable
        hide-details
        style="max-width: 260px; min-width: 180px"
      )

    v-card(v-if="loading && allTasks.length === 0" variant="flat")
      v-list(lines="two")
        loading-content(:lineCount="2" v-for="n in 3" :key="n")

    .tasks-page__list(v-else-if="groupedEntries.length > 0")
      v-card.tasks-page__group.mb-4(
        v-for="entry in groupedEntries"
        :key="entry.key"
        variant="flat"
      )
        .px-5.pt-4.pb-2
          .text-caption.text-medium-emphasis.mb-1(v-if="(!group || subgroupsFilter) && entry.group && entry.group.name") {{ entry.group.name }}
          router-link.text-title-medium.text-high-emphasis.text-decoration-none.underline-on-hover(:to="entry.url") {{ entry.title }}
        v-list.px-2.pb-2(density="comfortable")
          v-list-item.tasks-page__item(
            v-for="task in entry.tasks"
            :key="task.id"
          )
            template(#prepend)
              v-checkbox-btn.mr-2(
                :model-value="Boolean(task.doneAt)"
                :disabled="Boolean(task.processing) || task.canUpdate === false"
                @update:model-value="toggleDone(task)"
              )
            v-list-item-title.text-body-medium.text-wrap
              router-link.text-decoration-none.underline-on-hover(
                :to="entry.url"
                :class="task.doneAt ? 'text-decoration-line-through text-medium-emphasis' : 'text-high-emphasis'"
              ) {{ task.name }}
            template(#append v-if="task.dueOn")
              .d-flex.align-center.ga-1.text-caption.ml-3.text-no-wrap(:class="isOverdue(task) ? 'text-error' : 'text-medium-emphasis'")
                common-icon(name="mdi-calendar" size="14" :color="isOverdue(task) ? 'error' : undefined")
                span {{ formatDueDate(task.dueOn) }}

    v-card(v-else variant="flat")
      v-card-text.text-center.text-medium-emphasis.pa-6
        template(v-if="allTasks.length === 0") {{ t('tasks.no_tasks_assigned') }}
        template(v-else-if="hasActiveFilters") {{ t('tasks.no_matching_tasks') }}
        template(v-else) {{ t('tasks.no_open_tasks') }}

    .d-flex.justify-center.mt-6
      v-chip(variant="outlined" :href="manualUrl('user_manual/discussions/tasks', locale)" target="_blank")
        common-icon.mr-2(name="mdi-help-circle-outline")
        span {{ t('common.user_guide') }}: {{ t('tasks.tasks') }}
</template>
