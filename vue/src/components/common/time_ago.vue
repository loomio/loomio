<script lang="js">
import { approximate, exact } from '@/shared/helpers/format_time';
import { parseISO } from 'date-fns';
import {isString} from 'lodash-es';

export default {
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

<template>
<abbr class="time-ago" :title="exactDate(parsedDate)">{{approximateDate(parsedDate)}}</abbr>
</template>

<style lang="sass">
.time-ago
  white-space: nowrap
abbr[title]
  text-decoration: none
  border-bottom: none

</style>
