<script setup>
import { useI18n } from 'vue-i18n';
import { useRoute, useRouter } from 'vue-router';
import { mdiTagOutline } from '@mdi/js';
import { computed, ref, watch } from 'vue';
import { useWatchRecords } from '@/composables/useWatchRecords';

const { tag, group } = defineProps({tag: {type: String, required: true}, group: {type: Object, required: true}});
const { t } = useI18n();
const route = useRoute();
const router = useRouter();
const { watchRecords } = useWatchRecords();
const tags = ref([]);
const tagColor = computed(() => tags.value.find(record => record.name === tag)?.color);
const refreshTags = () => { tags.value = group.tags(); };

watch(() => group, refreshTags, {immediate: true});
watchRecords({collections: ['tags'], query: refreshTags});

function close() {
  const query = {...route.query};
  delete query.tag;
  router.push({path: route.path, query});
}
</script>

<template lang="pug">
v-banner.tag-filter-toolbar(lines="one" sticky :elevation="4" color="primary" role="region" :aria-label="t('common.action.filter')")
  template(v-slot:prepend)
    v-icon.tag-filter-toolbar__icon(:icon="mdiTagOutline" :color="tagColor")
  v-banner-text
    span {{ t('common.action.filter') }}:
    v-chip.ml-2(size="small" variant="tonal") {{ tag }}
  template(v-slot:actions)
    v-btn.tag-filter-toolbar__close(icon variant="text" :aria-label="t('common.action.close')" @click="close")
      common-icon(name="mdi-close")
</template>

<style>
.tag-filter-toolbar {
  top: 64px;
  z-index: 1;
}
</style>
