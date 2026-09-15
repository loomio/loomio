<script setup>
import { computed, onUnmounted, ref, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import Records from '@/shared/services/records';
import RecordLoader from '@/shared/services/record_loader';
import EventBus from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import { mdiMagnify } from '@mdi/js';
import { debounce, orderBy, uniq, escapeRegExp } from 'lodash-es';
import { useWatchRecords } from '@/composables/useWatchRecords';

const { group } = defineProps({
  group: {type: Object, required: true}
});
const route = useRoute();
const router = useRouter();
const { t } = useI18n();
const { watchRecords } = useWatchRecords();
const attachmentLoader = ref(new RecordLoader({
  collection: 'attachments',
  params: {group_id: group.id, per: 25, from: 0}
}));
const searchQuery = ref(route.query.q || '');
const items = ref([]);
const attachmentIds = ref([]);
const loading = computed(() => attachmentLoader.value.loading);
const canAdminister = computed(() => AbilityService.canAdminister(group));
const onQueryInput = debounce(value => router.replace({query: {q: value}}), 400);

function query() {
  const attachments = Records.attachments.collection.chain()
    .find({id: {$in: attachmentIds.value}})
    .find({filename: {$regex: new RegExp(escapeRegExp(searchQuery.value), 'i')}})
    .data();
  items.value = orderBy(attachments, 'createdAt', 'desc');
}

function fetch() {
  return attachmentLoader.value.fetchRecords({q: searchQuery.value}).then(data => {
    attachmentIds.value = uniq(attachmentIds.value.concat((data.attachments || []).map(attachment => attachment.id)));
  }).then(query);
}

function deleteAttachment(item) {
  EventBus.$emit('openModal', {
    component: 'ConfirmModal',
    props: {
      confirm: {
        submit: item.destroy,
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

EventBus.$emit('currentComponent', {
  page: 'groupPage',
  title: group.name,
  group,
  search: {placeholder: t('navbar.search_files', {name: group.parentOrSelf().name})}
});
watchRecords({collections: ['attachments'], query});
watch(() => route.query.q, value => {
  searchQuery.value = value || '';
  fetch();
  query();
});
onUnmounted(() => onQueryInput.cancel());
fetch();
</script>

<template lang="pug">
div
  .pt-4.pb-2
    v-text-field(
      clearable
      hide-details
      variant="solo"
      density="compact"
      @update:model-value="onQueryInput"
      :placeholder="$t('navbar.search_files_short')"
      :prepend-inner-icon="mdiMagnify")
  v-card.group-files-panel(variant="flat")
    div
      p.text-center.pa-4(v-if="!loading && !items.length" v-t="'common.no_results_found'")
      v-table(v-else :items="items" hide-default-footer)
        thead
          tr
            th(v-t="'group_files_panel.filename'")
            th(v-t="'group_files_panel.uploaded_by'")
            th(v-t="'group_files_panel.uploaded_at'")
            th(v-if="canAdminister")
        tbody
          tr(v-for="item in items" :key="item.id")
            td
              v-layout(align-center)
                common-icon.mr-2(:name="'mdi-'+ item.icon")
                a.text-medium-emphasis.text-decoration-none(:href="item.downloadUrl") {{item.filename}}
            td
              user-avatar(:user="item.author()")
            td
              time-ago(:date="item.createdAt")
            td(v-if="canAdminister")
              action-button(variant="flat" :action="{name: 'common.action.delete', icon: 'mdi-delete', dock: 1, perform: () => deleteAttachment(item)}")

      .d.flex.justify-center
        .d-flex.flex-column.justify-center.align-center
          v-btn.my-2(
            variant="tonal"
            color='primary'
            v-if="!attachmentLoader.exhausted"
            :loading="loading"
            @click="fetch()"
          )
            span(v-t="'common.action.load_more'")
</template>
