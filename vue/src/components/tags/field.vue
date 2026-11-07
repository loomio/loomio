<script setup lang="js">
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { VAutocomplete, VCombobox } from 'vuetify/components';
import { uniq } from 'lodash-es';
import AbilityService from '@/shared/services/ability_service';

const { model, template } = defineProps({ model: Object, template: Boolean });
const { t } = useI18n();

// Memberships and group permissions can arrive after the form mounts. Read
// from the record store so the field uses the same permissions as the server.
const items = computed(() => {
  if (template) { return []; }
  return uniq(model.group().tags().map(tag => tag.name));
});

const canCreateTags = computed(() => {
  if (template) { return true; }
  return !model.groupId || AbilityService.canCreateTags(model.group());
});

function colorFor(name) {
  if (template) { return; }
  return model.group().tags().find(tag => tag.name === name)?.color;
}
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
