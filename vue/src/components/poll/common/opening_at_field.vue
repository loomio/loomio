<script setup lang="js">
import { computed, onMounted, ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { format, formatDistance, parse, startOfHour, startOfDay, isValid, addDays } from 'date-fns';
import { hoursOfDay, timeFormat } from '@/shared/helpers/format_time';
import { mdiClockOutline } from '@mdi/js';

const { poll, disabled } = defineProps({
  poll: Object,
  disabled: {
    type: Boolean,
    default: false
  }
});

const { t } = useI18n();

const openingHour = ref(format(poll.openingAt || startOfHour(addDays(new Date(), 1)), 'HH:mm'));
const openingDate = ref(poll.openingAt || addDays(new Date(), 1));
const times = hoursOfDay();
const dateToday = startOfDay(new Date());

const twelvehour = computed(() => timeFormat() !== 'HH:mm');

const openingAtHint = computed(() => {
  if (!openingDate.value) { return null; }
  try {
    return format(openingDate.value, timeFormat());
  } catch {
    return null;
  }
});

const label = computed(() => {
  if (!openingDate.value) { return false; }
  return formatDistance(openingDate.value, new Date(), { addSuffix: true });
});

function updateOpeningAt() {
  if (disabled) return;
  const date = parse(`${format(openingDate.value, 'yyyy-MM-dd')} ${openingHour.value}`, 'yyyy-MM-dd HH:mm', new Date());
  if (isValid(date)) {
    poll.openingAt = date;
  }
}

onMounted(updateOpeningAt);
watch([openingDate, openingHour], updateOpeningAt);
</script>

<template lang="pug">
.poll-common-opening-at-field
  .poll-common-opening-at-field__inputs.d-flex
    v-date-input.mr-2(
      v-model="openingDate"
      input-format="yyyy-mm-dd"
      :label="t('poll_common_opening_at_field.opening_date')"
      :hint="label ? t('common.opening_in', { time: label }) : ''"
      :error-messages="poll.errors.openingAt"
      :min="dateToday"
      :disabled="disabled"
      persistent-hint
      hide-header
    )
    v-select.poll-common-opening-at-field__timepicker(
      :prepend-inner-icon="mdiClockOutline"
      v-model="openingHour"
      :label="t('poll_common_opening_at_field.opening_hour')"
      :items="times"
      :hint="twelvehour ? openingAtHint : null"
      :persistent-hint="twelvehour"
      :disabled="disabled"
    )
</template>
