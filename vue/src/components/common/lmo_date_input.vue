<script lang="js">
import Session from '@/shared/services/session';
import AppConfig from '@/shared/services/app_config';
import { format, utcToZonedTime } from 'date-fns-tz';
import { I18n, dateLocale } from '@/i18n';

export default {
  props: ['modelValue', 'label', 'hint', 'prependInnerIcon', 'min', 'clearable', 'disabled'],
  // props: ['label', 'hint'],
  emits: ['update:modelValue', 'click:clear'],
  data() {
    return {
      open: false,
      date: this.modelValue
    }
  },

  methods: {
    clickClear() {
      this.date = null;
      this.$emit('click:clear');
    },
    datePicked(val) {
      this.open = false;
      this.$emit('update:modelValue', this.date);
    }
  },
  computed: {
    formattedValue() {
      if (!this.date) { return null }
      const pattern = Session.user().dateTimePref.includes('iso') ? 'yyyy-MM-dd' : "d LLL yyyy"
      const zonedDate = utcToZonedTime(this.date, AppConfig.timeZone)
      return format(zonedDate, pattern, {timeZone: AppConfig.timeZone, locale: dateLocale});
    }
  }

}
</script>

<template lang="pug">
v-menu(
  :close-on-content-click="false"
  location="bottom"
  v-model="open"
  :disabled="disabled"
)
  template(template v-slot:activator="{ props }")
    v-text-field.mr-2(
      :clearable="clearable"
      @click:clear="clickClear"
      :prepend-inner-icon="prependInnerIcon"
      v-bind="props"
      :label="label"
      v-model="formattedValue"
      :hint="hint"
      readonly
      persistent-hint
      :disabled="disabled"
    )
  v-date-picker(
    hide-header
    v-model="date"
    @update:modelValue="datePicked(val)"
    :min="min"
  )
</template>
