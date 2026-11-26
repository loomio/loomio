<script lang="js">
const cachedAttachmentIds = new Map();
</script>

<script setup lang="js">
import { computed, ref, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { mdiMagnify } from '@mdi/js';
import { debounce, orderBy, uniq, escapeRegExp } from 'lodash-es';
import Records from '@/shared/services/records';
import RecordLoader from '@/shared/services/record_loader';
import EventBus from '@/shared/services/event_bus';
import GroupAbility from '@/shared/abilities/group_ability';
import SubgroupsFilterMenu from '@/components/group/subgroups_filter_menu.vue';
import { useFilesSummary } from '@/composables/useFilesSummary';

const { dashboard } = defineProps({
  dashboard: { type: Boolean, default: false }
});

const route = useRoute();
const router = useRouter();
const { t } = useI18n();
const { setFilesCount } = useFilesSummary();

const limit = 25;
const group = computed(() => (dashboard ? null : Records.groups.fuzzyFind(route.params.key)));
const searchQuery = ref(route.query.q || '');

const subgroupsFilter = computed(() => {
  if (!group.value || !(group.value.subgroupsCount > 0)) { return null; }
  return ['mine', 'all'].includes(route.query.subgroups) ? route.query.subgroups : null;
});

const cacheKey = computed(() => (
  `${group.value ? group.value.id : 'dashboard'}:${subgroupsFilter.value || 'none'}`
));

const attachmentIds = ref(cachedAttachmentIds.get(cacheKey.value) || []);
const attachmentLoader = ref(null);

function createLoader() {
  const params = { limit, offset: 0 };
  if (group.value) {
    params.group_id = group.value.id;
    if (subgroupsFilter.value) { params.subgroups = subgroupsFilter.value; }
  }
  attachmentLoader.value = new RecordLoader({
    collection: 'attachments',
    params
  });
}

function fetch() {
  return attachmentLoader.value.fetchRecords({ q: searchQuery.value }).then(data => {
    // RecordLoader resolves a failed request after recording its error.
    if (attachmentLoader.value.err) { return; }
    attachmentIds.value = uniq(attachmentIds.value.concat((data.attachments || []).map(a => a.id)));
    if (!searchQuery.value) {
      cachedAttachmentIds.set(cacheKey.value, attachmentIds.value);
      if (!subgroupsFilter.value && typeof data?.meta?.total === 'number') {
        setFilesCount(group.value?.id || null, data.meta.total);
      }
    }
  });
}

const onQueryInput = debounce(val => {
  const query = { ...route.query };
  if (val) { query.q = val; } else { delete query.q; }
  return router.replace({ query });
}, 400);

function selectSubgroups(val) {
  const query = { ...route.query };
  if (val) { query.subgroups = val; } else { delete query.subgroups; }
  router.replace({ query });
}

function deleteAttachment(item) {
  EventBus.$emit('openModal', {
    component: 'ConfirmModal',
    props: {
      confirm: {
        submit: () => item.destroy(),
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

const items = computed(() => {
  const attachments = Records.attachments.collection.chain()
    .find({ id: { $in: attachmentIds.value } })
    .find({ filename: { $regex: new RegExp(escapeRegExp(searchQuery.value), 'i') } })
    .data();
  return orderBy(attachments, 'createdAt', 'desc');
});

const loading = computed(() => Boolean(attachmentLoader.value?.loading));
const canAdminister = computed(() => Boolean(group.value) && GroupAbility.canUpdate(group.value));

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

createLoader();
fetch();

watch(() => route.query.q, val => {
  searchQuery.value = val || '';
  fetch();
});

watch([() => route.query.subgroups, () => group.value?.id], () => {
  attachmentIds.value = cachedAttachmentIds.get(cacheKey.value) || [];
  createLoader();
  fetch();
});
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
      loading(v-if="loading && !items.length")
      p.text-center.pa-4(v-else-if="!loading && !items.length") {{ t('common.no_results_found') }}
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

      .d.flex.justify-center
        .d-flex.flex-column.justify-center.align-center
          v-btn.my-2(
            variant="tonal"
            color="primary"
            v-if="items.length && !attachmentLoader.exhausted"
            :loading="loading"
            @click="fetch()"
          )
            span {{ t('common.action.load_more') }}
</template>
