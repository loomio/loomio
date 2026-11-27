<script setup lang="js">
import { ref, onMounted, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { debounce } from 'lodash-es';
import { mdiMagnify } from '@mdi/js';
import EventBus from '@/shared/services/event_bus';
import LmoUrlService from '@/shared/services/lmo_url_service';
import Records from '@/shared/services/records';
import UserModel from '@/shared/models/user_model';
import { usePeopleSummary } from '@/composables/usePeopleSummary';

const { embedded } = defineProps({
  embedded: { type: Boolean, default: false }
});

const { t } = useI18n();
const { setRecentlyOnlineCount, cachedPeople, cachedTotal, setCachedPeople } = usePeopleSummary();
const people = ref(cachedPeople.value);
const total = ref(cachedTotal.value);
const isLoading = ref(cachedPeople.value.length === 0);
const loadingMore = ref(false);
const query = ref('');
const limit = 30;

async function fetchPeople({ reset = true } = {}) {
  if (reset) {
    isLoading.value = true;
  } else {
    loadingMore.value = true;
  }

  try {
    const offset = reset ? 0 : people.value.length;
    const response = await Records.remote.get('memberships/people', {
      q: query.value.trim() || undefined,
      offset,
      limit
    });
    const nextUsers = (response.users || []).map(attrs => new UserModel(attrs));
    people.value = reset ? nextUsers : people.value.concat(nextUsers);
    total.value = response.total || 0;
    if (reset && !query.value.trim()) {
      setCachedPeople(nextUsers, total.value);
    }
    setRecentlyOnlineCount(response.recently_online_count);
  } finally {
    isLoading.value = false;
    loadingMore.value = false;
  }
}

const debouncedFetch = debounce(() => fetchPeople({ reset: true }), 250);
watch(query, () => debouncedFetch());

function profileUrl(user) {
  return LmoUrlService.route({ model: user });
}

function titleVisible(visible) {
  EventBus.$emit('content-title-visible', visible);
}

onMounted(() => {
  if (!embedded) {
    EventBus.$emit('content-title-visible', false);
    EventBus.$emit('currentComponent', {
      titleKey: 'dashboard_cards.people',
      page: 'dashboardPeoplePage',
      group: null
    });
  }
  fetchPeople({ reset: true });
});
</script>

<template lang="pug">
component(:is="embedded ? 'div' : 'v-main'")
  component(:is="embedded ? 'div' : 'v-container'" :class="embedded ? 'dashboard-people-page pt-2' : 'dashboard-people-page max-width-1024 px-2 px-sm-4'")
    template(v-if="!embedded")
      h1.text-headline-large.my-4(tabindex="-1" v-intersect="{handler: titleVisible}") {{ t('dashboard_page.dashboard') }}
      dashboard-cards

    .d-flex.align-center.flex-wrap.ga-2.pt-4.pb-2
      v-text-field.dashboard-people-page__search.flex-grow-1(
        v-model="query"
        :prepend-inner-icon="mdiMagnify"
        :placeholder="t('dashboard_cards.search_people')"
        variant="outlined"
        density="compact"
        clearable
        hide-details
      )

    v-card(v-if="isLoading && people.length === 0" variant="flat")
      loading

    v-card(v-else-if="people.length > 0" variant="flat")
      v-list(lines="two")
        v-list-item.dashboard-people-page__person(
          v-for="person in people"
          :key="person.id"
        )
          template(#prepend)
            user-avatar.mr-2(:user="person" :size="36")
          v-list-item-title
            router-link.text-high-emphasis.text-decoration-none.underline-on-hover(:to="profileUrl(person)") {{ person.name }}
          v-list-item-subtitle(v-if="person.lastSeenAt")
            span {{ t('common.action.last_seen') }}
            | &nbsp;
            time-ago(:date="person.lastSeenAt")
          template(#append)
            .d-flex.align-center.ga-2
              v-btn.dashboard-people-page__direct(
                color="primary"
                variant="tonal"
                size="small"
                :to="'/d/new?user_id=' + person.id"
              ) {{ t('dashboard_cards.direct_thread') }}
              v-btn.dashboard-people-page__profile(
                variant="text"
                size="small"
                :to="profileUrl(person)"
              ) {{ t('dashboard_cards.view_profile') }}

      .d-flex.justify-center.pa-3(v-if="people.length < total")
        v-btn(
          variant="tonal"
          color="primary"
          :loading="loadingMore"
          @click="fetchPeople({ reset: false })"
        ) {{ t('common.action.load_more') }}

    v-card(v-else variant="flat")
      v-card-text.text-center.text-medium-emphasis {{ t('dashboard_cards.no_people_found') }}
</template>
