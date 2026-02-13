<script lang="js">
import AppConfig from '@/shared/services/app_config';
import { format, formatDistance, parse, startOfHour, startOfDay, isValid, addDays } from 'date-fns';
import { hoursOfDay, exact, timeFormat } from '@/shared/helpers/format_time';
import { mdiClockOutline } from '@mdi/js'

export default {
  props: {
    poll: Object,
    disabled: {
      type: Boolean,
      default: false
    }
  },

  data() {
    return {
      mdiClockOutline,
      openingHour: format(this.poll.openingAt || startOfHour(addDays(new Date(), 1)), 'HH:mm'),
      openingDate: this.poll.openingAt || addDays(new Date(), 1),
      times: hoursOfDay(),
      timeZone: AppConfig.timeZone,
      dateToday: startOfDay(new Date()),
    };
  },

  mounted() {
    this.updateOpeningAt();
  },

  methods: {
    exact,
    updateOpeningAt() {
      if (this.disabled) return;
      const date = parse(`${format(this.openingDate, "yyyy-MM-dd")} ${this.openingHour}`, "yyyy-MM-dd HH:mm", new Date());
      if (isValid(date)) {
        this.poll.openingAt = date;
      }
    }
  },

  computed: {
    twelvehour() { return timeFormat() !== 'HH:mm'; },

    openingAtHint() {
      if (!this.openingDate) { return null; }
      try {
        return format(this.openingDate, timeFormat());
      } catch(e) {
        return null;
      }
    },

    label() {
      if (!this.openingDate) { return false; }
      return formatDistance(this.openingDate, new Date, {addSuffix: true});
    }
  },

  watch: {
    openingDate(val) {
      this.updateOpeningAt();
    },

    openingHour(val) { this.updateOpeningAt(); }
  }
};
</script>

<template lang="pug">
.poll-common-opening-at-field
  .poll-common-opening-at-field__inputs.d-flex
    v-date-input.mr-2(
      v-model='openingDate'
      input-format="yyyy-mm-dd"
      :label="$t('poll_common_opening_at_field.opening_date')"
      :hint="label ? $t('common.opening_in', { time: label }) : ''"
      :error-messages="poll.errors.openingAt"
      :min="dateToday"
      :disabled="disabled"
      persistent-hint
      hide-header
    )
    v-select.poll-common-opening-at-field__timepicker(
      :prepend-inner-icon="mdiClockOutline"
      v-model='openingHour'
      :label="$t('poll_common_opening_at_field.opening_hour')"
      :items="times"
      :hint="twelvehour ? openingAtHint : null"
      :persistent-hint="twelvehour"
      :disabled="disabled"
    )

</template>
