<script lang="js">
const cachedAttachmentIds = new Map();
</script>

<script setup lang="js">
import { computed, ref, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { mdiMagnify } from '@mdi/js';
import { debounce, escapeRegExp, identity, orderBy, pickBy } from 'lodash-es';
import Records from '@/shared/services/records';
import PageLoader from '@/shared/services/page_loader';
import EventBus from '@/shared/services/event_bus';
import GroupAbility from '@/shared/abilities/group_ability';
import SubgroupsFilterMenu from '@/components/group/subgroups_filter_menu.vue';
import ListPagination from '@/components/common/list_pagination.vue';
import { useFilesSummary } from '@/composables/useFilesSummary';

const { dashboard } = defineProps({
  dashboard: { type: Boolean, default: false }
});

const route = useRoute();
const router = useRouter();
const { t } = useI18n();
const { setFilesCount } = useFilesSummary();

const group = computed(() => (dashboard ? null : Records.groups.fuzzyFind(route.params.key)));
const searchQuery = ref(route.query.q || '');

const subgroupsFilter = computed(() => {
  if (!group.value || !(group.value.subgroupsCount > 0)) { return null; }
  return ['mine', 'all'].includes(route.query.subgroups) ? route.query.subgroups : null;
});

const sortOrder = computed(() => (
  ['oldest', 'name'].includes(route.query.sort) ? route.query.sort : 'newest'
));

const sortOptions = computed(() => [
  { value: 'newest', label: t('pagination.sort.newest') },
  { value: 'oldest', label: t('pagination.sort.oldest') },
  { value: 'name', label: t('pagination.sort.name') }
]);

const pageSize = computed(() => {
  const n = parseInt(route.query.limit, 10);
  return [25, 50, 100].includes(n) ? n : 25;
});

function mergeQuery(obj) {
  return { query: pickBy(Object.assign({}, route.query, obj), identity) };
}

const page = computed({
  get: () => parseInt(route.query.page) || 1,
  set: (val) => router.replace(mergeQuery({ page: val === 1 ? null : val }))
});

const cacheKey = computed(() => (
  `${group.value ? group.value.id : 'dashboard'}:${subgroupsFilter.value || 'none'}`
));

const attachmentLoader = ref(null);
const totalPages = computed(() => Math.max(1, Math.ceil((attachmentLoader.value?.total || 0) / pageSize.value)));

function createLoader() {
  const params = {
    limit: pageSize.value,
    q: searchQuery.value || undefined,
    sort: sortOrder.value === 'newest' ? undefined : sortOrder.value
  };
  if (group.value) {
    params.group_id = group.value.id;
    if (subgroupsFilter.value) { params.subgroups = subgroupsFilter.value; }
  }
  attachmentLoader.value = new PageLoader({
    path: 'attachments',
    order: 'createdAt',
    params
  });
}

function fetchPage() {
  return attachmentLoader.value.fetch(page.value).then(() => {
    if (attachmentLoader.value.err) { return; }
    const ids = attachmentLoader.value.pageIds[page.value] || [];
    if (!searchQuery.value && page.value === 1 && sortOrder.value === 'newest') {
      cachedAttachmentIds.set(cacheKey.value, ids);
      if (!subgroupsFilter.value && typeof attachmentLoader.value.total === 'number') {
        setFilesCount(group.value?.id || null, attachmentLoader.value.total);
      }
    }
  });
}

const onQueryInput = debounce(val => {
  return router.replace(mergeQuery({ q: val || null, page: null }));
}, 400);

function selectSubgroups(val) {
  router.replace(mergeQuery({ subgroups: val, page: null }));
}

function selectSort(val) {
  router.replace(mergeQuery({ sort: val === 'newest' ? null : val, page: null }));
}

function selectPageSize(val) {
  router.replace(mergeQuery({ limit: val === 25 ? null : val, page: null }));
}

function deleteAttachment(item) {
  EventBus.$emit('openModal', {
    component: 'ConfirmModal',
    props: {
      confirm: {
        submit: () => item.destroy().then(fetchPage),
        text: {
          title: 'comment_form.attachments.remove_attachment',
          helptext: 'group_files_panel.delete_confirmation',
          submit: 'common.action.delete',
          flash: 'poll_common_delete_modal.success'
        }
      }
    }
  });
}

const isLoading = computed(() => Boolean(attachmentLoader.value?.loading));

const items = computed(() => {
  const pageIds = attachmentLoader.value?.pageIds?.[page.value];
  if (Array.isArray(pageIds)) {
    return pageIds
      .map(id => Records.attachments.findById(id))
      .filter(Boolean);
  }

  if (page.value !== 1 || !isLoading.value) {
    return [];
  }

  const cachedIds = cachedAttachmentIds.get(cacheKey.value) || [];
  if (!cachedIds.length) { return []; }

  const attachments = Records.attachments.collection.chain()
    .find({ id: { $in: cachedIds } })
    .find({ filename: { $regex: new RegExp(escapeRegExp(searchQuery.value), 'i') } })
    .data();

  if (sortOrder.value === 'oldest') { return orderBy(attachments, 'createdAt', 'asc').slice(0, pageSize.value); }
  if (sortOrder.value === 'name') { return orderBy(attachments, a => (a.filename || '').toLowerCase(), 'asc').slice(0, pageSize.value); }
  return orderBy(attachments, 'createdAt', 'desc').slice(0, pageSize.value);
});

const canAdminister = computed(() => Boolean(group.value) && GroupAbility.canUpdate(group.value));

function emitCurrentComponent() {
  if (group.value) {
    EventBus.$emit('currentComponent', {
      page: 'groupPage',
      title: group.value.name,
      group: group.value,
      search: {
        placeholder: t('navbar.search_files', { name: group.value.parentOrSelf().name })
      }
    });
  }
}

emitCurrentComponent();
createLoader();
fetchPage();

watch(
  () => [group.value?.id, route.query.q, route.query.subgroups, route.query.sort, route.query.limit],
  ([nextGroupId], [prevGroupId]) => {
    searchQuery.value = route.query.q || '';
    if (nextGroupId !== prevGroupId) { emitCurrentComponent(); }
    createLoader();
    fetchPage();
  }
);

watch(() => route.query.page, fetchPage);
</script>

<template lang="pug">
div
  .d-flex.align-center.flex-wrap.ga-2.pt-4.pb-2
    subgroups-filter-menu(v-if="group" :group="group" :selected="subgroupsFilter" @select="selectSubgroups")
    v-text-field.flex-grow-1(
      :model-value="searchQuery"
      clearable
      hide-details
      variant="solo"
      density="compact"
      @update:model-value="onQueryInput"
      :placeholder="t('navbar.search_files_short')"
      :prepend-inner-icon="mdiMagnify"
    )
  v-card.group-files-panel(variant="flat")
    div
      loading(v-if="isLoading && !items.length")
      p.text-center.pa-4(v-else-if="!isLoading && !items.length") {{ t('common.no_results_found') }}
      v-table(v-else :items="items" hide-default-footer)
        thead
          tr
            th {{ t('group_files_panel.filename') }}
            th {{ t('group_files_panel.uploaded_by') }}
            th {{ t('group_files_panel.uploaded_at') }}
            th(v-if="canAdminister")
        tbody
          tr(v-for="item in items" :key="item.id")
            td
              v-layout(align-center)
                common-icon.mr-2(:name="'mdi-' + item.icon")
                a.text-medium-emphasis.text-decoration-none(:href="item.downloadUrl") {{ item.filename }}
            td
              user-avatar(:user="item.author()")
            td
              time-ago(:date="item.createdAt")
            td(v-if="canAdminister")
              action-button(variant="flat" :action="{ name: 'common.action.delete', icon: 'mdi-delete', dock: 1, perform: () => deleteAttachment(item) }")

      list-pagination(
        v-if="items.length"
        :page="page"
        :total-pages="totalPages"
        :page-size="pageSize"
        :sort="sortOrder"
        :sort-options="sortOptions"
        :disabled="isLoading"
        @update:page="page = $event"
        @update:page-size="selectPageSize"
        @update:sort="selectSort"
      )
</template>
