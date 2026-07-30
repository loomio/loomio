<script setup lang="js">
import { computed, ref, watch } from 'vue';
import { debounce } from 'lodash-es';
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
let requestId = 0;
const namedId = computed(() => mentionNamedIdFor(model));
const supported = computed(() => {
  return ['comment', 'discussion', 'poll', 'outcome', 'stance'].some(type => model.isA(type));
});
const promptVisible = computed(() => model.isA('comment') && empty && handles.length === 0);
const messageVisible = computed(() => {
  return supported.value && (promptVisible.value || (handles.length && count.value !== null));
});

const updateCount = debounce(() => {
  requestId += 1;
  const currentRequestId = requestId;

  if (!supported.value || !handles.length || !Object.keys(namedId.value).length) {
    count.value = null;
    return;
  }

  Records.remote.fetch({
    path: 'mentions/count',
    params: {
      handles_cmr: handles.join(','),
      ...namedId.value
    }
  }).then(data => {
    if (currentRequestId === requestId) {
      count.value = data.count;
    }
  }).catch(() => {
    if (currentRequestId === requestId) {
      count.value = null;
    }
  });
}, 150);

watch(
  [() => handles, () => JSON.stringify(namedId.value), supported],
  updateCount,
  { immediate: true }
);
</script>

<template lang="pug">
p.mention-notifications-count.text-medium-emphasis.text-body-small(
  v-show="messageVisible"
)
  span(v-if="promptVisible" v-t="'comment_form.type_at_to_notify_people'")
  span(v-else-if="count === 0" v-t="'mention_notifications_count.nobody_will_be_notified'")
  span(v-else-if="count === 1" v-t="'mention_notifications_count.one_person_will_be_notified'")
  span(
    v-else
    v-t="{path: 'mention_notifications_count.x_people_will_be_notified', args: {count}}"
  )
</template>

<style scoped lang="sass">
.mention-notifications-count
  position: absolute
  right: 12px
  bottom: 9px
  margin: 0
  padding-left: 8px
  pointer-events: none
  background: rgb(var(--v-theme-surface))
</style>
