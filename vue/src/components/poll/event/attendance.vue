<script setup>
import { computed, onScopeDispose, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { debounce } from 'lodash-es';
import Records from '@/shared/services/records';
import { useWatchRecords } from '@/composables/useWatchRecords';

const { poll, hideVoters = false } = defineProps({ poll: Object, hideVoters: Boolean });
const { t } = useI18n();
const { watchRecords } = useWatchRecords();
const rows = ref([]);
const crowds = ref({});
const noResponse = ref(0);
const limit = 50;
let revision = 0;
const labels = { agree: 'calendar.going', abstain: 'calendar.maybe', disagree: 'calendar.not_attending' };
const visibleRows = computed(() => rows.value.map(row => ({
  ...row, crowd: crowds.value[row.id] || { voters: [], loading: false, error: false }
})));

async function loadMore(row, currentRevision = revision) {
  const crowd = crowds.value[row.id];
  if (!crowd || crowd.loading || hideVoters || !poll.showResults()) return;
  crowd.loading = true;
  crowd.error = false;
  try {
    const data = await Records.fetch({path: `polls/${poll.id}/votes`, params: {
      poll_option_id: row.id, limit, offset: crowd.voters.length
    }});
    if (currentRevision !== revision || !poll.showResults()) return;
    // The endpoint omits choices if results become hidden while loading.
    const voters = data.voters.filter(voter => voter.vote_cast && Number((voter.option_scores || {})[row.id]) > 0);
    const known = new Set(crowd.voters.map(voter => voter.voter_id));
    crowd.voters.push(...voters.filter(voter => !known.has(voter.voter_id)));
  } catch {
    if (currentRevision === revision) crowd.error = true;
  } finally {
    if (currentRevision === revision) crowd.loading = false;
  }
}

const loadCrowds = debounce(currentRevision => {
  rows.value.filter(row => row.vote_count > 0).forEach(row => loadMore(row, currentRevision));
}, 100);

watchRecords({ collections: ['polls', 'stances'], query: () => {
  revision += 1;
  rows.value = Object.keys(labels).map(icon => poll.results.find(row => row.icon === icon)).filter(Boolean);
  noResponse.value = poll.results.find(row => row.id === -1)?.vote_count || 0;
  crowds.value = Object.fromEntries(rows.value.map(row => [row.id, {voters: [], loading: false, error: false}]));
  if (!hideVoters && poll.showResults()) loadCrowds(revision);
}});

onScopeDispose(() => { revision += 1; loadCrowds.cancel(); });
</script>

<template>
  <section v-if="poll.showResults()" class="poll-event-attendance" :aria-label="t('calendar.attendance')">
    <div class="poll-event-attendance__crowds">
      <section v-for="row in visibleRows" :key="row.id" class="poll-event-attendance__group" :class="`poll-event-attendance__group--${row.icon}`" :style="{'border-top-color': row.color}">
        <h3 class="text-title-medium mb-3 d-flex align-center ga-2">
          <span>{{ t(labels[row.icon]) }}</span>
          <span class="poll-event-attendance__count text-medium-emphasis">{{ row.vote_count }}</span>
        </h3>
        <div v-if="!hideVoters" class="poll-event-attendance__avatars" :aria-busy="row.crowd.loading">
          <v-tooltip v-for="voter in row.crowd.voters" :key="voter.voter_id" :text="voter.voter_name">
            <template #activator="{ props }">
              <v-avatar v-bind="props" :image="voter.voter_thumb_url" :size="36" :aria-label="voter.voter_name" :title="voter.voter_name" role="img" tabindex="0" color="surface-variant">
                <span v-if="!voter.voter_thumb_url" class="text-label-small">{{ voter.voter_avatar_initials }}</span>
              </v-avatar>
            </template>
          </v-tooltip>
        </div>
        <p v-if="row.crowd.error" role="alert" class="text-body-small mt-2">{{ t('calendar.load_attendance_error') }}</p>
        <v-btn v-if="!hideVoters && row.vote_count > row.crowd.voters.length" class="poll-event-attendance__more mt-2" variant="text" size="small" :loading="row.crowd.loading" @click="loadMore(row)">
          {{ t('calendar.show_more') }} · {{ row.vote_count - row.crowd.voters.length }}
        </v-btn>
      </section>
    </div>
    <p class="poll-event-attendance__no-response text-body-small text-medium-emphasis mt-4">{{ t('calendar.no_response') }}: {{ noResponse }}</p>
  </section>
</template>

<style scoped>
.poll-event-attendance__crowds {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 16px;
}
.poll-event-attendance__group {
  border-top: 3px solid;
  padding-top: 12px;
}
.poll-event-attendance__count {
  font-variant-numeric: tabular-nums;
}
.poll-event-attendance__avatars {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}
@media (max-width: 599px) {
  .poll-event-attendance__crowds { grid-template-columns: minmax(0, 1fr); }
}
</style>
