<script lang="js">
import Records     from '@/shared/services/records';
import FlashService   from '@/shared/services/flash';
import { times } from 'lodash-es';
import { hoursOfDay, timeFormat } from '@/shared/helpers/format_time';
import { format, parse, isValid } from 'date-fns';
import I18n from '@/i18n';

export default {
  props: {
    value: Date,
    min: Date,
    dateLabel: Object,
    timeLabel: Object
  },

  created() {
    return this.newValue = this.value;
  },

  data() {
    return {
      dateStr: (this.value && format(this.value, 'yyyy-MM-dd')) || '',
      timeStr: (this.value && format(this.value, 'HH:mm')) || '',
      minStr:  (this.value && format(this.min, 'yyyy-MM-dd')) || '',
      dateMenu: false,
      times: hoursOfDay(),
      placeholder: format(new Date(), 'yyyy-MM-dd'),
      validDate: val => {
        return isValid(parse(val, "yyyy-MM-dd", new Date()));
      }
    };
  },

  methods: {
    updateNewValue() {
      const val = parse(`${this.dateStr} ${this.timeStr}`, "yyyy-MM-dd HH:mm", new Date);
      if (!isValid(val)) { return; }
      this.newValue = val;
      this.$emit('input', this.newValue);
    }
  },

  watch: {
    dateStr() { this.updateNewValue(); },
    timeStr() { this.updateNewValue(); }
  },

  computed: {
    twelvehour() { return timeFormat() !== 'HH:mm'; },
    timeHint() {
      try {
        const d = parse(this.timeStr, 'HH:mm', new Date);
        return format(d, timeFormat());
      } catch (error) {
        FlashService.error("poll_meeting_form.use_24_hour_format", {time: format(new Date, 'HH:mm')});
        return I18n.t("poll_meeting_form.use_24_hour_format", {time: format(new Date, 'HH:mm')});
      }
    }
  }
};
</script>
<template lang="pug">
v-layout.date-time-picker
  v-menu(ref='dateTimePicker' v-model='dateMenu' offset-y min-width='290px')
    template(v-slot:activator='{ on, attrs }')
      v-text-field.date-time-picker__date-field(
        v-model='dateStr'
        v-on='on'
        v-bind='attrs'
        :placeholder="placeholder"
        :rules="[validDate]"
        prepend-icon="mdi-calendar")
    v-date-picker.date-time-picker__date-picker(
      v-model='dateStr'
      no-title
      :min='minStr'
      @input="dateMenu = false")
  v-spacer
  v-combobox.date-time-picker__time-field(
    :hint="twelvehour ? timeHint : null"
    :persistent-hint="twelvehour"
    v-model="timeStr"
    :items="times"
    prepend-icon="mdi-clock-outline")
</template>
