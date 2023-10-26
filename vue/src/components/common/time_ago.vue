<script lang="js">
import { approximate, exact } from '@/shared/helpers/format_time';
import { parseISO } from 'date-fns';
import {isString} from 'lodash';

export default {
  props: {
    date: [Date, String]
  },

  data() {
    return {parsedDate: null};
  },

  created() {
    if (isString(this.date)) {
      this.parsedDate = parseISO(this.date);
    } else {
      this.parsedDate = this.date;
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
