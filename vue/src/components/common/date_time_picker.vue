<script lang="js">
import AppConfig from '@/shared/services/app_config';
import { hoursOfDay, timeFormat } from '@/shared/helpers/format_time';
import { format, parse, isValid } from 'date-fns';
import { utcToZonedTime, zonedTimeToUtc } from 'date-fns-tz';
import { mdiClockOutline } from '@mdi/js';
import { I18n } from '@/i18n';

export default {
  props: {
    modelValue: Date,
    min: Date,
    timeZone: {
      type: String,
      default: () => AppConfig.timeZone
    }
  },

  created() {
    return this.newValue = this.value;
  },

  data() {
    return {
      mdiClockOutline,
      dateVal: utcToZonedTime(this.modelValue || new Date(), this.timeZone),
      timeStr: (this.modelValue && format(utcToZonedTime(this.modelValue, this.timeZone), 'HH:mm')) || '12:00',
      times: hoursOfDay(),
      dateToday: utcToZonedTime(new Date(), this.timeZone),
      validDate: val => {
        return isValid(parse(val, "yyyy-MM-dd", new Date()));
      }
    };
  },

  methods: {
    parseTime(value) {
      return parse(value || '', 'HH:mm', new Date());
    },

    validTime(value) {
      return isValid(this.parseTime(value)) || I18n.global.t(
        'poll_meeting_form.use_24_hour_format',
        {time: format(new Date(), 'HH:mm')}
      );
    },

    updateNewValue() {
      const val = parse(`${format(this.dateVal, "yyyy-MM-dd")} ${this.timeStr}`, "yyyy-MM-dd HH:mm", new Date);
      if (!isValid(val)) { return; }
      this.newValue = zonedTimeToUtc(val, this.timeZone);
      this.$emit('update:modelValue', this.newValue);
    }
  },

  watch: {
    dateVal() { this.updateNewValue(); },
    timeStr() { this.updateNewValue(); }
  },

  computed: {
    twelvehour() { return timeFormat() !== 'HH:mm'; },
    timeHint() {
      const time = this.parseTime(this.timeStr);
      return isValid(time) ? format(time, timeFormat()) : null;
    }
  }
};
</script>
<template lang="pug">
.d-flex.date-time-picker.flex-grow-1
  v-date-input.mr-2(
    v-model='dateVal'
    input-format="yyyy-mm-dd"
    :hint="timeZone"
    :min="dateToday"
    persistent-hint
    hide-header
  )
  v-combobox.date-time-picker__time-field(
    :hint="twelvehour ? timeHint : null"
    :persistent-hint="twelvehour"
    v-model="timeStr"
    :items="times"
    :rules="[validTime]"
    :prepend-inner-icon="mdiClockOutline")
</template>
