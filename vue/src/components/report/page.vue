<script lang="js">
import AppConfig          from '@/shared/services/app_config';
import Records            from '@/shared/services/records';
import Session            from '@/shared/services/session';
import {subMonths, startOfMonth } from 'date-fns';
import { mdiCalendar } from '@mdi/js';

import BarChart from '@/components/report/bar_chart';

const sumValues = obj => Object.values(obj).reduce((a, b) => a + b, 0);


export default {
  components: {BarChart},
  data() {
    return {
      mdiCalendar: mdiCalendar,
      loading: false,
      chartData: {
        labels: [],
        datasets: []
      },
      all_groups: [],
      group_ids: this.$route.query['group_ids'].split(',').map(id => parseInt(id)),
      start_menu: false,
      end_menu: false,
      start_month: (this.$route.query['start_on'] || (new Date(2019,1,1)).toISOString().slice(0,7)),
      end_month: (new Date()).toISOString().slice(0,7),
      interval: 'month',
      intervalItems: [
        {text: this.$t('report.day'), value: 'day'},
        {text: this.$t('report.week'), value: 'week'},
        {text: this.$t('report.month'), value: 'month'},
        {text: this.$t('report.year'), value: 'year'}
      ],
      total_users: 0,
      discussions_count: 0,
      polls_count: 0,
      discussions_with_polls_count: 0,
      polls_with_outcomes_count: 0,
      models_per_interval: [],
      models_per_interval_headers: [
        {text: "Date", value: "date"},
        {text: this.$t('common.threads'), value: "threads"},
        {text: this.$t('navbar.search.comments'), value: "comments"},
        {text: this.$t('group_page.polls'), value: "polls"},
        {text: this.$t('poll_common.votes'), value: "votes"},
        {text: this.$t('poll_common.outcomes'), value: "outcomes"},
      ],
      tags_headers: [
        {text: "Tag", value: "tag"},
        {text: this.$t('poll_meeting_chart_panel.total'), value: "total_count"},
        {text: this.$t('common.threads'), value: "threads_count"},
        {text: this.$t('group_page.polls'), value: "polls_count"},
      ],
      tags_rows: [],
      per_user_headers: [
        {text: "User", value: "user"},
        {text: this.$t('report.country'), value: "country"},
        {text: this.$t('common.threads'), value: "threads"},
        {text: this.$t('navbar.search.comments'), value: "comments"},
        {text: this.$t('group_page.polls'), value: "polls"},
        {text: this.$t('poll_common.votes'), value: "votes"},
        {text: this.$t('poll_common.outcomes'), value: "outcomes"},
        {text: "Reactions", value: "reactions"},
      ],
      per_user_rows: [],
      users_per_country_rows: [],
      users_per_country_headers: [
        {text: this.$t('report.country'), value: 'country'},
        {text: this.$t('report.users'), value: 'users'},
      ],
      per_country_rows: [],
      per_country_headers: [
        {text: 'Country', value: 'country' },
        {text: this.$t('common.threads'), value: "threads"},
        {text: this.$t('navbar.search.comments'), value: "comments"},
        {text: this.$t('group_page.polls'), value: "polls"},
        {text: this.$t('poll_common.votes'), value: "votes"},
        {text: this.$t('poll_common.outcomes'), value: "outcomes"},
        {text: "Reactions", value: "reactions"},
      ]
    };
  },

  mounted() {
    this.fetch();
  },

  watch: {
    start_month(val) {
      this.fetch();
    },
    end_month(val) {
      this.fetch();
    },
    interval(val) {
      this.fetch();
    }
  },
  methods: {
    fetch() {
      this.loading = true
      const query = new URLSearchParams({interval: this.interval, start_month: this.start_month, end_month: this.end_month, group_ids: this.group_ids.join(',')}).toString()
      fetch('/api/v1/reports?'+query).then(response => {
        response.json().then(data => {
          this.loading = false;
          this.all_groups = data.all_groups,
          this.total_users = data.total_users;
          this.discussions_count = data.discussions_count;
          this.polls_count = data.polls_count;
          this.discussions_with_polls_count = data.discussions_with_polls_count;
          this.polls_with_outcomes_count = data.polls_with_outcomes_count;

          this.chartData = {
            labels: data.intervals,
            datasets: [
              {
                label: this.$t('common.threads'),
                backgroundColor: '#2196F3',
                data: data.intervals.map(interval => (data.discussions_per_interval[interval] || 0) )
              },
              {
                label: this.$t('navbar.search.comments'),
                backgroundColor: '#009688',
                data: data.intervals.map(interval => (data.comments_per_interval[interval] || 0) )
              },
              {
                label: this.$t('group_page.polls'),
                backgroundColor: '#4CAF50',
                data: data.intervals.map(interval => (data.polls_per_interval[interval] || 0) )
              },
              {
                label: this.$t('poll_common.votes'),
                backgroundColor: '#E91E63',
                data: data.intervals.map(interval => (data.stances_per_interval[interval] || 0) )
              },
              {
                label: this.$t('poll_common.outcomes'),
                backgroundColor: '#FF9800',
                data: data.intervals.map(interval => (data.outcomes_per_interval[interval] || 0) )
              },
            ]
          },

          this.models_per_interval = data.intervals.map(interval => {
            return {
              date: interval,
              threads: data.discussions_per_interval[interval] || 0,
              comments: data.comments_per_interval[interval] || 0,
              polls: data.polls_per_interval[interval] || 0,
              votes: data.stances_per_interval[interval] || 0,
              outcomes: data.outcomes_per_interval[interval] || 0,
            }
          });

          this.models_per_interval.push({
            date: 'total',
            threads: sumValues(data.discussions_per_interval),
            comments: sumValues(data.comments_per_interval),
            polls: sumValues(data.polls_per_interval),
            votes: sumValues(data.stances_per_interval),
            outcomes: sumValues(data.outcomes_per_interval),
          });

          this.tags_rows = data.tag_names.map(tag => {
            return {
              tag: tag,
              total_count: data.tag_counts[tag],
              threads_count: data.discussion_tag_counts[tag],
              polls_count: data.poll_tag_counts[tag],
            };
          });

          this.per_user_rows = data.users.map(user => {
            return {
              user: user.name,
              country: user.country,
              threads: data.discussions_per_user[user.id] || 0,
              comments: data.comments_per_user[user.id] || 0,
              polls: data.polls_per_user[user.id] || 0,
              votes: data.stances_per_user[user.id] || 0,
              outcomes: data.outcomes_per_user[user.id] || 0,
              reactions: data.reactions_per_user[user.id] || 0,
            }
          });

          this.users_per_country_rows = data.countries.map(country => {
            return {
              country: country,
              users: data.users_per_country[country]
            }
          });

          this.per_country_rows = data.countries.map(country => {
            return {
              country: country,
              threads: data.discussions_per_country[country] || 0,
              comments: data.comments_per_country[country] || 0,
              polls: data.polls_per_country[country] || 0,
              votes: data.stances_per_country[country] || 0,
              outcomes: data.outcomes_per_country[country] || 0,
              reactions: data.reactions_per_country[country] || 0,
            }
          });
        });
      });
    }
  },
};

</script>

<template lang="pug">
v-main
  v-container.report-page.max-width-900
    h1.text-h4.mb-8(v-t="'group_page.participation_report'")

    v-select(
      :label="$t('common.groups')"
      v-model="group_ids"
      :items="all_groups"
      item-text="name"
      item-value="id"
      multiple
      small-chips
      @blur="fetch()"
    )

    .d-flex
      v-menu(
        ref="start_menu"
        v-model="start_menu"
        :close-on-content-click="false"
        transition="scale-transition"
        offset-y
        max-width="290px"
        min-width="auto"
      )
        template(v-slot:activator="{ on, attrs }")
          v-text-field(
            v-model="start_month"
            :label="$t('report.start_on')"
            readonly
            :prepend-icon="mdiCalendar"
            v-bind="attrs"
            v-on="on"
          )
        v-sheet
          v-date-picker(
            v-model="start_month"
            type="month"
            no-title
            scrollable
            @input="start_menu = false"
            :max="(new Date()).toISOString()"
          )
      v-menu(
        ref="end_menu"
        v-model="end_menu"
        :close-on-content-click="false"
        transition="scale-transition"
        offset-y
        max-width="290px"
        min-width="auto"
      )
        template(v-slot:activator="{ on, attrs }")
          v-text-field(
            v-model="end_month"
            :label="$t('report.end_on')"
            :prepend-icon="mdiCalendar"
            readonly
            v-bind="attrs"
            v-on="on"
          )
        v-sheet
          v-date-picker(
            v-model="end_month"
            type="month"
            no-title
            scrollable
            @input="end_menu = false"
            :max="(new Date()).toISOString()"
          )

      v-select.ml-8(
        :label="$t('report.interval')"
        v-model="interval"
        :items="intervalItems"
      )


    .d-flex.justify-center
      v-progress-circular(indeterminate color="primary" v-if="loading")

    div(v-if="!loading")

      v-simple-table.mt-8
        thead
          th.pt-4(v-t="'report.total_users'")
          th.pt-4(v-t="'report.total_threads'")
          th.pt-4(v-t="'report.total_polls'")
          th.pt-4(v-t="'report.threads_with_polls'")
          th.pt-4(v-t="'report.polls_with_outcomes'")
        tbody
          tr
            td.text-center {{total_users}}
            td.text-center {{discussions_count}}
            td.text-center {{polls_count}}
            td.text-center {{discussions_with_polls_count}}
            td.text-center {{polls_with_outcomes_count}}

      bar-chart.mt-8(:chart-data="chartData")

      v-card.mt-8
        v-card-title(v-t="{path: 'report.actions_per_interval', args: {interval: interval}}")
        v-data-table(
          density="dense"
          disable-pagination
          hide-default-footer
          :headers="models_per_interval_headers"
          :items="models_per_interval"
        )

      v-card.mt-8
        v-card-title(v-t="'loomio_tags.tags'")
        v-data-table(
          density="dense"
          disable-pagination
          hide-default-footer
          :headers="tags_headers"
          :items="tags_rows"
        )

      v-card.mt-8
        v-card-title(v-t="'report.actions_per_user'")
        v-data-table(
          density="dense"
          disable-pagination
          hide-default-footer
          :headers="per_user_headers"
          :items="per_user_rows"
          :items-per-page="50"
        )

      v-card.mt-8
        v-card-title(v-t="'report.users_per_country'")
        p.px-4.text-caption(v-t="'report.country_disclaimer'")
        v-data-table(
          density="dense"
          disable-pagination
          hide-default-footer
          :headers="users_per_country_headers"
          :items="users_per_country_rows"
        )

      v-card.mt-8
        v-card-title(v-t="'report.actions_per_country'")
        v-data-table(
          density="dense"
          disable-pagination
          hide-default-footer
          :headers="per_country_headers"
          :items="per_country_rows"
        )

</template>


<style lang="sass">
.report-page .v-data-table
  max-height: 100vh
  overflow-y: auto

</style>
