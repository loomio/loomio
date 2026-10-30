<script setup>
import { computed, onScopeDispose, ref, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { useDisplay } from 'vuetify';
import { VCalendar } from 'vuetify/components/VCalendar';
import { mdiCalendarCheck, mdiCalendarClock, mdiChevronLeft, mdiChevronRight } from '@mdi/js';
import { addDays, addMonths, addWeeks, endOfMonth, endOfWeek, format, parseISO, startOfMonth, startOfWeek } from 'date-fns';
import { utcToZonedTime } from 'date-fns-tz';
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import AbilityService from '@/shared/services/ability_service';
import Flash from '@/shared/services/flash';
import { useWatchRecords } from '@/composables/useWatchRecords';

const route = useRoute();
const router = useRouter();
const { t, locale } = useI18n();
const { smAndDown } = useDisplay();
const group = ref(null);
const day = ref(format(new Date(), 'yyyy-MM-dd'));
const view = ref(smAndDown.value ? 'upcoming' : 'month');
const entries = ref([]);
const loading = ref(false);
const error = ref(false);
const subscriptionOpen = ref(false);
const subscriptionUrl = ref('');
const subscriptionLoading = ref(false);
const subscriptionError = ref(false);
const copied = ref(false);
const isMember = computed(() => group.value && group.value.membersInclude(Session.user()));
const canCreateEvent = computed(() => group.value && AbilityService.canStartPoll(group.value));
const views = computed(() => ['month', 'week', 'day', 'upcoming'].map(value => ({title: t('calendar.' + value), value})));
const timeZone = computed(() => Session.user().timeZone);
const calendarEntries = computed(() => entries.value.map(entry => ({
  ...entry,
  name: entry.cancelled ? `${t('calendar.cancelled')}: ${entry.name}` : entry.name,
  start: entry.timed ? format(utcToZonedTime(parseISO(entry.start), timeZone.value), 'yyyy-MM-dd HH:mm') : entry.start,
  end: entry.timed ? format(utcToZonedTime(parseISO(entry.end), timeZone.value), 'yyyy-MM-dd HH:mm') : format(addDays(parseISO(entry.end), -1), 'yyyy-MM-dd')
})));
const bounds = computed(() => {
  const selected = parseISO(day.value);
  switch (view.value) {
    case 'upcoming': return [selected, addDays(selected, 90)];
    case 'day': return [selected, addDays(selected, 1)];
    case 'week': return [startOfWeek(selected), addDays(endOfWeek(selected), 1)];
    default: return [startOfWeek(startOfMonth(selected)), addDays(endOfWeek(endOfMonth(selected)), 1)];
  }
});

let requestNumber = 0;
async function loadEntries() {
  const request = ++requestNumber;
  entries.value = [];
  if (!isMember.value) { loading.value = false; return; }
  loading.value = true;
  error.value = false;
  try {
    const data = await Records.remote.get(`groups/${group.value.id}/calendar`, {
      start: format(bounds.value[0], 'yyyy-MM-dd'), end: format(bounds.value[1], 'yyyy-MM-dd')
    });
    if (request === requestNumber) entries.value = data.entries;
  } catch {
    if (request === requestNumber) error.value = true;
  } finally {
    if (request === requestNumber) loading.value = false;
  }
}

function navigate(direction) {
  const change = view.value === 'month' ? addMonths : view.value === 'week' ? addWeeks : addDays;
  day.value = format(change(parseISO(day.value), direction), 'yyyy-MM-dd');
}
function openEntry(_click, context) {
  const url = new URL(context.event.url);
  router.push(url.pathname + url.search);
}
function color(entry) {
  return entry.cancelled ? 'secondary' : entry.kind === 'event' ? 'primary' : entry.kind === 'deadline' ? 'info' : 'secondary';
}
async function loadSubscription(reset = false) {
  if (reset && !window.confirm(t('calendar.reset_link_confirm'))) return;
  subscriptionLoading.value = true;
  subscriptionError.value = false;
  copied.value = false;
  try {
    const action = reset ? 'reset_calendar_subscription' : 'calendar_subscription';
    const data = await Records.remote.post(`groups/${group.value.id}/${action}`, {});
    subscriptionUrl.value = data.url;
  } catch {
    subscriptionError.value = true;
  } finally {
    subscriptionLoading.value = false;
  }
}
async function copySubscription() {
  try {
    await navigator.clipboard.writeText(subscriptionUrl.value);
    copied.value = true;
  } catch (error) {
    Flash.serverError(error);
  }
}

let groupRequest = 0;
watch(() => route.params.key, async key => {
  const request = ++groupRequest;
  group.value = null;
  subscriptionOpen.value = false;
  subscriptionUrl.value = '';
  try {
    const fetched = await Records.groups.findOrFetch(key);
    if (request === groupRequest) group.value = fetched;
  } catch {
    if (request === groupRequest) error.value = true;
  }
}, { immediate: true });
onScopeDispose(() => { groupRequest++; requestNumber++; });
watch([bounds, isMember], loadEntries);
const { watchRecords } = useWatchRecords();
watchRecords({ collections: ['polls', 'outcomes'], query: loadEntries });
</script>

<template>
  <section class="group-calendar-panel py-4" :aria-label="t('calendar.calendar')">
    <v-alert v-if="error && !isMember" type="error" variant="tonal">{{ t('calendar.load_error') }}</v-alert>
    <v-alert v-if="group && !isMember" type="info" variant="tonal">{{ t('calendar.members_only') }}</v-alert>
    <template v-if="isMember">
      <div class="d-flex flex-wrap align-center ga-2 mb-4">
        <h2 class="text-title-large">{{ t('calendar.calendar') }}</h2>
        <v-spacer />
        <v-btn v-if="canCreateEvent" :to="{path: '/p/new', query: {group_id: group.id, template_key: 'event'}}">{{ t('calendar.create_event') }}</v-btn>
        <v-btn class="group-calendar-subscribe" @click="subscriptionOpen = true; loadSubscription()">{{ t('calendar.subscribe') }}</v-btn>
      </div>
      <div class="d-flex flex-wrap align-center ga-2 mb-4">
        <v-btn :icon="mdiChevronLeft" :aria-label="t('calendar.previous')" @click="navigate(-1)" />
        <v-btn @click="day = format(new Date(), 'yyyy-MM-dd')">{{ t('calendar.today') }}</v-btn>
        <v-btn :icon="mdiChevronRight" :aria-label="t('calendar.next')" @click="navigate(1)" />
        <span class="text-title-medium">{{ format(parseISO(day), 'MMMM yyyy') }}</span>
        <v-spacer />
        <v-select v-model="view" :items="views" :label="t('calendar.view')" hide-details style="max-width: 180px" />
      </div>
      <p class="text-body-small text-medium-emphasis mb-2">{{ timeZone }}</p>
      <v-progress-linear v-if="loading" indeterminate :aria-label="t('common.loading')" />
      <v-alert v-if="error" type="error" variant="tonal">{{ t('calendar.load_error') }}</v-alert>
      <v-calendar v-if="view !== 'upcoming'" v-model="day" :type="view" :events="calendarEntries" :event-color="color" :locale="locale" style="height: 600px" @click:event="openEntry" />
      <v-list v-else>
        <v-list-item v-for="entry in calendarEntries" :key="entry.id" :title="entry.name" :subtitle="entry.start" @click="openEntry(null, {event: entry})">
          <template #prepend><v-icon :color="color(entry)" :icon="entry.kind === 'event' ? mdiCalendarCheck : mdiCalendarClock" /></template>
        </v-list-item>
        <v-list-item v-if="!loading && !error && !entries.length" :title="t('calendar.no_upcoming')" />
      </v-list>
    </template>

    <v-dialog v-model="subscriptionOpen" max-width="640">
      <v-card class="group-calendar-subscription" :title="t('calendar.subscribe')">
        <v-card-text>
          <p class="mb-4">{{ t('calendar.subscription_hint') }}</p>
          <v-alert v-if="subscriptionError" type="error" variant="tonal" class="mb-4">{{ t('calendar.load_error') }}</v-alert>
          <v-text-field class="group-calendar-link" :model-value="subscriptionUrl" :label="t('calendar.calendar_link')" readonly :loading="subscriptionLoading" />
          <p class="mb-4">{{ t('calendar.private_link_hint') }}</p>
          <v-btn :disabled="!subscriptionUrl || subscriptionLoading" @click="copySubscription">{{ t(copied ? 'calendar.link_copied' : 'calendar.copy_link') }}</v-btn>
          <ul class="my-4 pl-4">
            <li>{{ t('calendar.google_instructions') }}</li>
            <li>{{ t('calendar.outlook_instructions') }}</li>
            <li>{{ t('calendar.apple_instructions') }}</li>
          </ul>
          <p class="text-body-small text-medium-emphasis">{{ t('calendar.refresh_hint') }}</p>
        </v-card-text>
        <v-card-actions>
          <v-btn :disabled="subscriptionLoading" @click="loadSubscription(true)">{{ t('calendar.reset_link') }}</v-btn>
          <v-spacer />
          <v-btn @click="subscriptionOpen = false">{{ t('common.action.close') }}</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </section>
</template>
