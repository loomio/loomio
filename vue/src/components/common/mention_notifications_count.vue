<script setup lang="js">
import { computed, ref, watch } from 'vue';
import Records from '@/shared/services/records';
import { mentionNamedIdFor } from '@/components/lmo_textarea/composables/useMentioning';

const { model, handles, empty } = defineProps({
  model: {
    type: Object,
    required: true
  },
  handles: {
    type: Array,
    default: () => []
  },
  empty: {
    type: Boolean,
    default: false
  }
});

const count = ref(null);
const requestParams = computed(() => {
  if (!handles.length || !model.isA('comment', 'discussion', 'poll', 'outcome', 'stance')) return null;

  const context = mentionNamedIdFor(model);
  if (!Object.keys(context).length) return null;

  return {handles_cmr: [...new Set(handles)].sort().join(','), ...context};
});
const promptVisible = computed(() => model.isA('comment') && empty && handles.length === 0);

watch(
  () => JSON.stringify(requestParams.value),
  (_key, _previous, onCleanup) => {
    count.value = null;
    const params = requestParams.value;
    if (!params) return;

    let active = true;
    const timer = setTimeout(() => {
      Records.remote.fetch({path: 'mentions/count', params})
        .then(data => {
          if (active) count.value = data.count;
        })
        .catch(() => {});
    }, 150);
    onCleanup(() => {
      active = false;
      clearTimeout(timer);
    });
  },
  { immediate: true }
);
</script>

<template lang="pug">
p.mention-notifications-count.text-medium-emphasis.text-body-small(
  v-if="promptVisible || count !== null"
)
  span(v-if="promptVisible" v-t="'comment_form.type_at_to_notify_people'")
  span(v-else-if="count === 0" v-t="'mention_notifications_count.nobody_will_be_notified'")
  span(v-else-if="count === 1" v-t="'mention_notifications_count.one_person_will_be_notified'")
  span(
    v-else
    v-t="{path: 'mention_notifications_count.x_people_will_be_notified', args: {count}}"
  )
</template>

<style scoped>
.mention-notifications-count {
  position: absolute;
  right: 12px;
  bottom: 9px;
  margin: 0;
  padding-left: 8px;
  pointer-events: none;
  background: rgb(var(--v-theme-surface));
}
</style>
