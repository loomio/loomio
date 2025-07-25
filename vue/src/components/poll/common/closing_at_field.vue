<script lang="js">
import AppConfig from '@/shared/services/app_config';
import { format, formatDistance, parse, startOfHour, startOfDay,  isValid, addHours, isAfter } from 'date-fns';
import { hoursOfDay, exact, timeFormat} from '@/shared/helpers/format_time';
import { mdiClockOutline, mdiCalendar } from '@mdi/js'

export default {
  props: {
    poll: Object
  },

  data() {
    return {
      mdiCalendar,
      mdiClockOutline,
      closingHour: format(this.poll.closingAt || startOfHour(new Date()), 'HH:mm'),
      closingDate: this.poll.closingAt || new Date(),
      times: hoursOfDay(),
      timeZone: AppConfig.timeZone,
      dateToday: startOfDay(new Date()),
      isShowingDatePicker: false,
    };
  },

  methods: {
    exact,
    updateClosingAt() {
      const date = parse(`${format(this.closingDate, "yyyy-MM-dd")} ${this.closingHour}`, "yyyy-MM-dd HH:mm", new Date());
      if (isValid(date)) {
        this.poll.closingAt = date;
      }
    }
  },

  computed: {
    twelvehour() { return timeFormat() !== 'HH:mm'; },

    closingAtHint() {
      return format(this.poll.closingAt, timeFormat());
    },

    label() {
      if (!this.poll.closingAt) { return false; }
      return formatDistance(this.poll.closingAt, new Date, {addSuffix: true});
    }
  },

  watch: {
    closingDate(val) {
      this.updateClosingAt();
    },

    closingHour(val) { this.updateClosingAt(); }
  }
};
</script>

<template lang="pug">
div
  .poll-common-closing-at-field.mt-4.mb-8
    .poll-common-closing-at-field__inputs.d-flex
      lmo-date-input.mr-2(
        v-model='closingDate'
        :prepend-inner-icon="mdiCalendar"
        :label="$t('poll_common_closing_at_field.closing_date')"
        :hint="$t('common.closing_in', { time: label })"
        :min="dateToday"
      )
      v-select.poll-common-closing-at-field__timepicker(
        :prepend-inner-icon="mdiClockOutline"
        v-model='closingHour'
        :label="$t('poll_meeting_time_field.closing_hour')"
        :items="times"
        :hint="twelvehour ? closingAtHint : null"
        :persistent-hint="twelvehour"
      )
    validation-errors(:subject="poll", field="closingAt")

</template>
