<script setup lang="js">
import Records from '@/shared/services/records';
import Flash   from '@/shared/services/flash';
import { ref, computed } from 'vue';

const { tag, group, close } = defineProps({
  tag: {
    type: Object,
    required: true
  },
  group: {
    type: Object,
    required: true
  },
  close: Function
});

const loading = ref(false);
const mergeIntoName = ref(null);

const tags = computed(() => {
  return group.tags().filter(t => t.id !== tag.id).sort((a, b) => a.name.localeCompare(b.name));
});

const tagNames = computed(() => tags.value.map(t => t.name));

function submit() {
  const mergeInto = tags.value.find(t => t.name === mergeIntoName.value);
  if (!mergeInto) { return; }

  loading.value = true;
  const mergedTag = Records.tags.find(tag.id).clone();
  mergedTag.name = mergeInto.name;
  mergedTag.color = mergeInto.color;
  mergedTag.save().then(() => {
    mergeInto.remove();
    Flash.success('loomio_tags.tag_merged');
    close();
  }).catch(err => Flash.serverError(err)).finally(() => {
    loading.value = false;
  });
}
</script>

<template lang="pug">
v-card.tags-merge-modal(:title="$t('loomio_tags.merge')")
  template(v-slot:append)
    dismiss-modal-button(:close="close")
  v-card-text
    p.text-medium-emphasis(v-t="{path: 'loomio_tags.merge_helptext', args: {name: tag.name}}")
    v-select.tags-merge-modal__tag(
      v-model="mergeIntoName"
      :items="tagNames"
      :label="$t('loomio_tags.merge_into')"
      autofocus
    )
  v-card-actions
    v-spacer
    v-btn.tags-merge-modal__submit(
      variant="elevated"
      color="primary"
      :disabled="!mergeIntoName"
      :loading="loading"
      @click="submit"
    )
      span(v-t="'loomio_tags.merge'")
</template>
