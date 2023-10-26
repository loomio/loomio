<script lang="js">
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
import EventBus from '@/shared/services/event_bus';
import AppConfig from '@/shared/services/app_config';
import Session from '@/shared/services/session';

import {sum, map, sortBy, find, compact, uniq} from 'lodash';

export default
  ({
    props: {
      poll: Object,
      zone: Object
    },

    data() {
      return {decidedVoters: []};
    },

    created() {
      return this.watchRecords({
        collections: ['users'],
        query: store => {
          this.decidedVoters = this.poll.decidedVoters();
        }
      });
    },

    methods: {
      scoreColor(score) {
        switch (score) {
          case 2: return AppConfig.pollColors.proposal[0];
          case 1: return AppConfig.pollColors.proposal[1];
          case 0: return AppConfig.pollColors.proposal[2];
        }
      },

      bgColor(score) {
        switch (score) {
          case 2: return "rgba(0, 209, 119, 0.5)";
          case 1: return "rgba(246, 168, 43, 0.5)";
        }
      },

      classForScore(score) {
        switch (score) {
          case 2: return 'poll-meeting-chart__cell--yes';
          case 1: return 'poll-meeting-chart__cell--maybe';
          default:
            return 'poll-meeting-chart__cell--no';
        }
      }
    },

    computed: {
      datesAsOptions() { return this.poll.datesAsOptions(); },
      currentUserTimeZone() {
        return Session.user().timeZone;
      }
    }
  });
</script>

<template lang="pug">
.poll-meeting-chart-panel
  table.poll-meeting-chart-table
    thead
      tr
        td.text--secondary(v-if="datesAsOptions") {{currentUserTimeZone}}
        td.pr-2.total.text--secondary(v-t="'poll_common.votes'")
        td(v-for="user in decidedVoters" :key="user.id")
          user-avatar(:user="user" :size="24")
    tbody
      tr(v-for="option in poll.results" :key="option.id")
        td.poll-meeting-chart__meeting-time
          poll-meeting-time(v-if="datesAsOptions" :name='option.name' :zone='zone')
          span(v-if="option.name_format == 'i18n'" v-t="option.name")
          span(v-if="option.name_format == 'none'") {{option.name}} 
        td.total.text-right.pr-2
          span(v-if="poll.canRespondMaybe") {{option.score/2}}
          span(v-else="poll.canRespondMaybe") {{option.score}}
        td(v-for="user in decidedVoters" :key="user.id")
          .poll-meeting-chart__cell(:class="classForScore(option.voter_scores[user.id])")
            | &nbsp;
</template>

<style lang="sass">
.poll-meeting-chart-panel
  overflow-x: scroll

.poll-meeting-chart-table
  width: auto
  background-color: none

.poll-meeting-chart-table tbody tr:hover
  background-color: #EEE

.theme--dark
  .poll-meeting-chart-table tbody tr:hover
    background-color: #333

.poll-meeting-chart__bar
  border: 1px solid
  margin: 4px 0px
  /* padding: 0 2px */
  display: flex
  flex-direction: row
  align-items: center
  justify-content: space-around
  border-radius: 2px

.poll-meeting-chart__cell
  width: 24px
  height: 24px
  border-radius: 2px
.poll-meeting-chart__cell--yes
  background-color: #00D177

.poll-meeting-chart__cell--maybe
  background-color: #F6A82B

.poll-meeting-chart__meeting-time
  font-family: 'Roboto Mono'
  font-size: 12px
  padding-right: 24px

.total
  padding-left: 24px
</style>
