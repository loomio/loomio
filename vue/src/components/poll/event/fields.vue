<script setup>
import { computed, ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { addDays, addHours, format, parseISO, startOfHour } from 'date-fns';
import { utcToZonedTime, zonedTimeToUtc } from 'date-fns-tz';
import Session from '@/shared/services/session';
import Records from '@/shared/services/records';

const { poll } = defineProps({ poll: { type: Object, required: true } });
const { t, locale } = useI18n();
const zones = ref([]);
poll.timeZone ||= Session.user().timeZone;
if (!poll.eventStartsAt) {
  poll.eventStartsAt = poll.eventAllDay
    ? zonedTimeToUtc(format(addDays(utcToZonedTime(new Date(), poll.timeZone), 1), 'yyyy-MM-dd'), poll.timeZone)
    : startOfHour(addDays(new Date(), 1));
}
if (!poll.eventEndsAt) {
  poll.eventEndsAt = poll.eventAllDay
    ? zonedTimeToUtc(format(addDays(utcToZonedTime(poll.eventStartsAt, poll.timeZone), 1), 'yyyy-MM-dd'), poll.timeZone)
    : addHours(poll.eventStartsAt, 1);
}
if (poll.isNew()) poll.closingAt = poll.eventStartsAt;

Records.fetch({ path: 'profile/all_time_zones', params: { selected_locale: locale.value } })
  .then(items => { zones.value = items; });

const local = date => format(utcToZonedTime(date, poll.timeZone), poll.eventAllDay ? 'yyyy-MM-dd' : "yyyy-MM-dd'T'HH:mm");
const start = computed({
  get: () => local(poll.eventStartsAt),
  set: value => {
    if (!value) return;
    const oldStart = poll.eventStartsAt;
    const duration = poll.eventEndsAt - oldStart;
    poll.eventStartsAt = zonedTimeToUtc(value, poll.timeZone);
    if (poll.closingAt?.getTime() === oldStart.getTime()) poll.closingAt = poll.eventStartsAt;
    if (poll.eventEndsAt <= poll.eventStartsAt) poll.eventEndsAt = new Date(poll.eventStartsAt.getTime() + duration);
  }
});
const end = computed({
  get: () => poll.eventAllDay ? format(addDays(utcToZonedTime(poll.eventEndsAt, poll.timeZone), -1), 'yyyy-MM-dd') : local(poll.eventEndsAt),
  set: value => {
    if (!value) return;
    const date = poll.eventAllDay ? format(addDays(parseISO(value), 1), 'yyyy-MM-dd') : value;
    poll.eventEndsAt = zonedTimeToUtc(date, poll.timeZone);
  }
});

watch(() => poll.eventAllDay, allDay => {
  if (!allDay) return;
  const date = format(utcToZonedTime(poll.eventStartsAt, poll.timeZone), 'yyyy-MM-dd');
  const wasDeadline = poll.closingAt?.getTime() === poll.eventStartsAt.getTime();
  poll.eventStartsAt = zonedTimeToUtc(date, poll.timeZone);
  poll.eventEndsAt = zonedTimeToUtc(format(addDays(parseISO(date), 1), 'yyyy-MM-dd'), poll.timeZone);
  if (wasDeadline) poll.closingAt = poll.eventStartsAt;
});
watch(() => poll.timeZone, (zone, previous) => {
  if (!poll.eventAllDay) return;
  const wasDeadline = poll.closingAt?.getTime() === poll.eventStartsAt.getTime();
  const dates = [poll.eventStartsAt, poll.eventEndsAt].map(date => format(utcToZonedTime(date, previous), 'yyyy-MM-dd'));
  poll.eventStartsAt = zonedTimeToUtc(dates[0], zone);
  poll.eventEndsAt = zonedTimeToUtc(dates[1], zone);
  if (wasDeadline) poll.closingAt = poll.eventStartsAt;
});
</script>

<template>
  <section class="poll-event-fields my-4">
    <v-checkbox v-model="poll.eventAllDay" :label="t('calendar.all_day')" hide-details />
    <div class="d-flex flex-wrap ga-4">
      <v-text-field v-model="start" :type="poll.eventAllDay ? 'date' : 'datetime-local'" :label="t('calendar.starts_at')" :error-messages="poll.errors.eventStartsAt" required />
      <v-text-field v-model="end" :type="poll.eventAllDay ? 'date' : 'datetime-local'" :label="t(poll.eventAllDay ? 'calendar.last_day' : 'calendar.ends_at')" :error-messages="poll.errors.eventEndsAt" required />
    </div>
    <v-autocomplete v-model="poll.timeZone" :items="zones" :label="t('calendar.time_zone')" :error-messages="poll.errors.timeZone" />
    <v-text-field class="poll-event-location" v-model="poll.eventLocation" :label="t('calendar.location')" />
    <p class="text-body-medium text-medium-emphasis">{{ t('calendar.invitation_hint') }}</p>
  </section>
</template>
