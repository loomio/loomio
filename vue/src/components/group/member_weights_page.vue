<script setup lang="js">
import { computed, onMounted, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRoute, useRouter } from 'vue-router';
import { debounce } from 'lodash-es';
import { mdiMagnify } from '@mdi/js';
import Records from '@/shared/services/records';
import AbilityService from '@/shared/services/ability_service';
import Flash from '@/shared/services/flash';
import LmoUrlService from '@/shared/services/lmo_url_service';
import { voteWeightValid } from '@/shared/helpers/vote_weight';

const limit = 50;
const { t } = useI18n();
const route = useRoute();
const router = useRouter();
const group = ref(null);
const memberships = ref([]);
const membershipTotal = ref(0);
const page = ref(1);
const query = ref('');
// Drafts and loaded weights are keyed by membership id and kept across pages
// and searches, so saving sends every edited weight and nothing else.
const weightsDraft = ref({});
const weightsLoaded = ref({});
const resetWeight = ref('1');
const resetDialog = ref(false);
const isLoading = ref(true);
const fetching = ref(false);
const saving = ref(false);
let fetchSequence = 0;

const membersPath = computed(() => group.value && LmoUrlService.route({model: group.value, action: 'members'}));
const totalPages = computed(() => Math.max(1, Math.ceil(membershipTotal.value / limit)));
const pageFirst = computed(() => membershipTotal.value ? (page.value - 1) * limit + 1 : 0);
const pageLast = computed(() => Math.min(page.value * limit, membershipTotal.value));
const editedIds = computed(() => Object.keys(weightsDraft.value).filter(id => Number(weightsDraft.value[id]) !== Number(weightsLoaded.value[id])));
const weightsValid = computed(() => editedIds.value.every(id => voteWeightValid(weightsDraft.value[id])));

// The weights endpoint returns plain rows, so shape each one like a user for
// the shared avatar, which colours initials by user id.
function avatarUser(membership) {
  return {
    id: membership.user_id,
    name: membership.name,
    thumbUrl: membership.avatar_url,
    avatarUrl: membership.avatar_url,
    avatarKind: 'initials',
    avatarInitials: membership.avatar_initials
  };
}

function openResetDialog() {
  resetWeight.value = '1';
  resetDialog.value = true;
}

// Ignore responses from an older page or search.
async function loadWeights() {
  const sequence = ++fetchSequence;
  fetching.value = true;
  try {
    const response = await Records.memberships.remote.get('weights', {
      group_id: group.value.id, q: query.value, offset: (page.value - 1) * limit, limit
    });
    if (sequence !== fetchSequence) return;
    memberships.value = response.memberships;
    membershipTotal.value = response.total;
    memberships.value.forEach(membership => {
      weightsLoaded.value[membership.id] = membership.weight;
      if (!(membership.id in weightsDraft.value)) weightsDraft.value[membership.id] = membership.weight;
    });
  } finally {
    if (sequence === fetchSequence) fetching.value = false;
  }
}

function reloadAfterSave() {
  weightsDraft.value = {};
  weightsLoaded.value = {};
  return loadWeights();
}

const search = debounce(value => {
  query.value = value || '';
  page.value = 1;
  loadWeights().catch(error => Flash.fromServer(error));
}, 300);

function changePage(nextPage) {
  page.value = nextPage;
  loadWeights().catch(error => Flash.fromServer(error));
}

async function saveWeights() {
  const weights = Object.fromEntries(editedIds.value.map(id => [id, weightsDraft.value[id]]));
  saving.value = true;
  try {
    await Records.remote.patch('memberships/set_weights', {group_id: group.value.id, weights});
    Flash.success('poll_common_form.vote_weights_updated');
    await reloadAfterSave();
  } catch (error) {
    Flash.fromServer(error);
  } finally {
    saving.value = false;
  }
}

async function resetWeights() {
  saving.value = true;
  try {
    await Records.remote.patch('memberships/reset_weights', {group_id: group.value.id, weight: resetWeight.value});
    resetDialog.value = false;
    Flash.success('poll_common_form.vote_weights_updated');
    await reloadAfterSave();
  } catch (error) {
    Flash.fromServer(error);
  } finally {
    saving.value = false;
  }
}

onMounted(async () => {
  try {
    group.value = await Records.groups.findOrFetch(route.params.key);
    if (!AbilityService.canAdminister(group.value)) {
      await router.replace(membersPath.value);
      return;
    }
    await loadWeights();
  } catch (error) {
    Flash.fromServer(error);
  } finally {
    isLoading.value = false;
  }
});
</script>

<template lang="pug">
.member-weights-page
  loading(v-if="isLoading")
  template(v-else-if="group")
    .d-flex.align-center.justify-space-between.pt-4.pb-2
      h2.text-title-medium.mb-0 {{ t('members_panel.edit_vote_weights') }}
      v-btn.member-weights-page__set-all(variant="tonal" @click="openResetDialog") {{ t('poll_common_form.set_all_vote_weights') }}
    p.text-body-medium.text-medium-emphasis.mb-4
      span {{ t('members_panel.vote_weights_are_defaults') }}
      help-link.ml-1(path="user_manual/polls/weighted_voting")
    v-text-field.member-weights-page__search(
      :model-value="query"
      @update:model-value="search"
      :placeholder="t('navbar.search_members_short')"
      :prepend-inner-icon="mdiMagnify"
      density="compact"
      variant="outlined"
      clearable
      hide-details)
    v-table
      thead
        tr
          th(scope="col") {{ t('group_page.members') }}
          th(scope="col") {{ t('auth_form.email') }}
          th.text-right(scope="col") {{ t('membership_form.weight_label') }}
      tbody
        tr(v-for="membership in memberships" :key="membership.id")
          td
            .d-flex.align-center.ga-2
              user-avatar(:user="avatarUser(membership)" :size="36" no-link)
              span {{ membership.name }}
              span.text-medium-emphasis(v-if="membership.title") {{ membership.title }}
              v-chip(v-if="membership.delegate" size="x-small" variant="tonal" label) {{ t('members_panel.delegate') }}
          td {{ membership.email }}
          td.text-right
            v-text-field.member-weights-page__weight-input(
              v-model="weightsDraft[membership.id]"
              type="text"
              inputmode="decimal"
              density="compact"
              hide-details
              :error="!voteWeightValid(weightsDraft[membership.id])"
              :aria-label="t('poll_common_form.vote_weight_for', {name: membership.name})")
        tr(v-if="query && memberships.length == 0 && !fetching")
          td(colspan="3") {{ t('discussions_panel.no_results_found', { search: query }) }}
    .d-flex.flex-wrap.align-center.justify-space-between.ga-2.py-2
      span.member-weights-page__page-count.text-body-small.text-medium-emphasis {{ t('strand_members_list.member_page_count', {first: pageFirst, last: pageLast, total: membershipTotal}) }}
      v-pagination.member-weights-page__pagination(
        v-if="totalPages > 1"
        :model-value="page"
        :length="totalPages"
        :total-visible="7"
        :disabled="fetching"
        @update:model-value="changePage")
    .d-flex.justify-end.mt-4
      v-btn.member-weights-page__save(color="primary" :disabled="editedIds.length == 0 || !weightsValid || saving" :loading="saving" @click="saveWeights") {{ t('poll_common_form.save_vote_weights') }}
    v-dialog(v-model="resetDialog" max-width="400")
      v-card.member-weights-page__reset-dialog(:title="t('poll_common_form.set_all_vote_weights')")
        v-card-text
          v-text-field.member-weights-page__reset-weight(
            v-model="resetWeight"
            type="text"
            inputmode="decimal"
            :label="t('poll_common_form.weight_for_all')"
            :error="!voteWeightValid(resetWeight)")
        v-card-actions
          v-spacer
          v-btn(variant="text" :disabled="saving" @click="resetDialog = false") {{ t('common.action.cancel') }}
          v-btn.member-weights-page__reset-save(color="primary" :disabled="!voteWeightValid(resetWeight) || saving" :loading="saving" @click="resetWeights") {{ t('common.action.save') }}
</template>

<style scoped>
.member-weights-page__weight-input { width: 112px; margin-left: auto; }
</style>
