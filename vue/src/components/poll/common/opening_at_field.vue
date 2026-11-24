<script setup lang="js">
import { computed, onMounted, ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { addDays, format, formatDistance, isValid, parse, startOfDay, startOfHour } from 'date-fns';
import { hoursOfDay, timeFormat } from '@/shared/helpers/format_time';
import { mdiClockOutline } from '@mdi/js';

const { t } = useI18n();

const { poll, disabled = false } = defineProps({
  poll: Object,
  disabled: {
    type: Boolean,
    default: false
  }
});

const defaultOpeningAt = poll.openingAt || startOfHour(addDays(new Date(), 1));
const openingHour = ref(format(defaultOpeningAt, 'HH:mm'));
const openingDate = ref(defaultOpeningAt);
const times = hoursOfDay();
const dateToday = startOfDay(new Date());

function updateOpeningAt() {
  if (disabled || !isValid(openingDate.value)) return;
  const date = parse(`${format(openingDate.value, 'yyyy-MM-dd')} ${openingHour.value}`, 'yyyy-MM-dd HH:mm', new Date());
  if (isValid(date)) {
    poll.openingAt = date;
  }
}

const twelvehour = computed(() => timeFormat() !== 'HH:mm');

const openingAtHint = computed(() => {
  if (!isValid(poll.openingAt)) return null;
  return format(poll.openingAt, timeFormat());
});

const label = computed(() => {
  if (!isValid(poll.openingAt)) return '';
  return formatDistance(poll.openingAt, new Date(), { addSuffix: true });
});

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
