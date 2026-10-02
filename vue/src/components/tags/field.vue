<script setup lang="js">
import { ref, watch, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';
import { VAutocomplete, VCombobox } from 'vuetify/components';
import { uniq } from 'lodash-es';
import AbilityService from '@/shared/services/ability_service';
import { useWatchRecords } from '@/composables/useWatchRecords';

const { model } = defineProps({ model: Object });
const { t } = useI18n();
const { watchRecords } = useWatchRecords();
const items = ref([]);
const canCreateTags = ref(false);

// Memberships and group permissions can arrive after the form mounts. Refresh
// from the record store so the field uses the same permissions as the server.
function refresh() {
  const group = model.group();
  items.value = uniq(group.tags().map(tag => tag.name));
  canCreateTags.value = !model.groupId || AbilityService.canCreateTags(group);
}

function colorFor(name) {
  return model.group().tags().find(tag => tag.name === name)?.color;
}

watch(() => model.groupId, refresh, { immediate: true });
onMounted(() => {
  watchRecords({
    key: 'tagsField',
    collections: ['tags', 'groups', 'memberships'],
    query: refresh
  });
});
</script>

<template lang="pug">
component.tags-field__input(
  :is="canCreateTags ? VCombobox : VAutocomplete"
  multiple
  chips
  closable-chips
  :return-object="false"
  v-model="model.tags"
  :label="t('loomio_tags.tags')"
  :items="items"
  )
  template(v-slot:chip="{ internalItem, props: chipProps }")
    v-chip.chip--select-multi(v-bind="chipProps" :color="colorFor(internalItem.value)") {{ internalItem.title }}
</template>
