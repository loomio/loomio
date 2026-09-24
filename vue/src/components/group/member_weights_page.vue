<script setup lang="js">
import { computed, onMounted, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRoute, useRouter } from 'vue-router';
import Records from '@/shared/services/records';
import AbilityService from '@/shared/services/ability_service';
import Flash from '@/shared/services/flash';
import LmoUrlService from '@/shared/services/lmo_url_service';
import { voteWeightValid } from '@/shared/helpers/vote_weight';

const { t } = useI18n();
const route = useRoute();
const router = useRouter();
const group = ref(null);
const memberships = ref([]);
const weightsDraft = ref({});
const resetWeight = ref('1');
const resetDialog = ref(false);
const isLoading = ref(true);
const saving = ref(false);

const membersPath = computed(() => group.value && LmoUrlService.route({model: group.value, action: 'members'}));
const weightsDirty = computed(() => memberships.value.some(membership => Number(weightsDraft.value[membership.id]) !== Number(membership.weight)));
const weightsValid = computed(() => memberships.value.every(membership => voteWeightValid(weightsDraft.value[membership.id])));

function openResetDialog() {
  resetWeight.value = '1';
  resetDialog.value = true;
}

// Use the dedicated endpoint so the form includes every active membership,
// regardless of the members panel's filters or pagination.
async function loadWeights() {
  const response = await Records.memberships.remote.get('weights', {group_id: group.value.id});
  memberships.value = response.memberships;
  weightsDraft.value = Object.fromEntries(memberships.value.map(membership => [membership.id, membership.weight]));
}

async function saveWeights() {
  const weights = Object.fromEntries(memberships.value
    .filter(membership => Number(weightsDraft.value[membership.id]) !== Number(membership.weight))
    .map(membership => [membership.id, weightsDraft.value[membership.id]]));
  saving.value = true;
  try {
    await Records.remote.patch('memberships/set_weights', {group_id: group.value.id, weights});
    await loadWeights();
    Flash.success('poll_common_form.vote_weights_updated');
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
    await loadWeights();
    resetDialog.value = false;
    Flash.success('poll_common_form.vote_weights_updated');
  } catch (error) {
    Flash.fromServer(error);
  } finally {
    saving.value = false;
  }
}

onMounted(async () => {
  try {
    group.value = await Records.groups.findOrFetch(route.params.key);
    if (!group.value.voteWeightsAllowed || !AbilityService.canAdminister(group.value)) {
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
              v-avatar(size="36")
                v-img(v-if="membership.avatar_url" :src="membership.avatar_url")
                span(v-if="!membership.avatar_url") {{ membership.avatar_initials }}
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
              :aria-label="t('poll_common_form.vote_weight_for', {name: membership.name})")
    .d-flex.justify-end.mt-4
      v-btn.member-weights-page__save(color="primary" :disabled="!weightsDirty || !weightsValid || saving" :loading="saving" @click="saveWeights") {{ t('poll_common_form.save_vote_weights') }}
    v-dialog(v-model="resetDialog" max-width="400")
      v-card.member-weights-page__reset-dialog(:title="t('poll_common_form.set_all_vote_weights')")
        v-card-text
          v-text-field.member-weights-page__reset-weight(
            v-model="resetWeight"
            type="text"
            inputmode="decimal"
            :label="t('poll_common_form.weight_for_all')"
            :error-messages="voteWeightValid(resetWeight) ? [] : [t('membership_form.weight_invalid_decimal')]")
        v-card-actions
          v-spacer
          v-btn(variant="text" :disabled="saving" @click="resetDialog = false") {{ t('common.action.cancel') }}
          v-btn.member-weights-page__reset-save(color="primary" :disabled="!voteWeightValid(resetWeight) || saving" :loading="saving" @click="resetWeights") {{ t('common.action.save') }}
</template>

<style scoped>
.member-weights-page__weight-input { width: 112px; margin-left: auto; }
</style>
