<script lang="js">
import { approximate, exact } from '@/shared/helpers/format_time';
import { parseISO } from 'date-fns';
import {isString} from 'lodash-es';
import FormatDate from '@/mixins/format_date';

export default {
  mixins: [FormatDate],
  props: {
    date: [Date, String]
  },

  computed: {
    parsedDate() {
      if (isString(this.date)) {
        return parseISO(this.date);
      } else {
        return this.date;
      }
    }
  }
};
</script>

<template lang="pug">
abbr.time-ago(:title='exactDate(parsedDate)') {{approximateDate(parsedDate)}}
</template>

<style lang="sass">
.time-ago
  white-space: nowrap
abbr[title]
  text-decoration: none
  border-bottom: none

</style>
