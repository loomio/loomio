<script setup>
import { useI18n } from 'vue-i18n';
import { exact } from '@/shared/helpers/format_time';
import { computed } from 'vue';
import { addDays, format } from 'date-fns';
import { utcToZonedTime } from 'date-fns-tz';

const { poll } = defineProps({ poll: { type: Object, required: true } });
const { t } = useI18n();
const dates = computed(() => {
  const start = format(utcToZonedTime(poll.eventStartsAt, poll.timeZone), 'yyyy-MM-dd');
  const end = format(addDays(utcToZonedTime(poll.eventEndsAt, poll.timeZone), -1), 'yyyy-MM-dd');
  return start === end ? start : `${start} – ${end}`;
});
</script>

<template>
  <div class="poll-event-details mb-4">
    <v-alert v-if="poll.eventCancelledAt" type="info" variant="tonal" class="mb-2">{{ t('calendar.cancelled') }}</v-alert>
    <p v-if="poll.eventAllDay"><strong>{{ dates }}</strong> · {{ t('calendar.all_day') }}</p>
    <p v-else><strong>{{ exact(poll.eventStartsAt) }}</strong> – {{ exact(poll.eventEndsAt) }}</p>
    <p v-if="poll.eventLocation">{{ poll.eventLocation }}</p>
    <p class="text-body-small text-medium-emphasis">{{ t('calendar.attendance_hint') }}</p>
  </div>
</template>
