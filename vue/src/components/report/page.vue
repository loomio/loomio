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
  computed: {
    startMonths() {
      let months = [];
      let next = null;
      for (let year = this.firstYear; year <= new Date().getFullYear(); year++) {
        for (let month = 1; month <= 12; month++) {
          next = year+"-"+String(month).padStart(2, '0');
          months.push(next);
          if (next > new Date().toISOString().slice(0,7)) {
            return months;
          }
        }
      }
    },
    endMonths() {
      let months = [];
      let next = null;
      let firstYear = new Date(this.start_month + "-01").getFullYear();
      for (let year = firstYear; year <= new Date().getFullYear(); year++) {
        for (let month = 1; month <= 12; month++) {
          next = year+"-"+String(month).padStart(2, '0');
          months.push(next);
          if (next > new Date().toISOString().slice(0,7)) {
            return months;
          }
        }
      }
    }
  },
  data() {
    return {
      firstYear: 2011,
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
        {title: this.$t('report.day'), value: 'day'},
        {title: this.$t('report.week'), value: 'week'},
        {title: this.$t('report.month'), value: 'month'},
        {title: this.$t('report.year'), value: 'year'}
      ],
      total_users: 0,
      discussions_count: 0,
      polls_count: 0,
      discussions_with_polls_count: 0,
      polls_with_outcomes_count: 0,
      models_per_interval: [],
      models_per_interval_headers: [
        {title: "Date", key: "date"},
        {title: this.$t('common.threads'), key: "threads"},
        {title: this.$t('navbar.search.comments'), key: "comments"},
        {title: this.$t('group_page.polls'), key: "polls"},
        {title: this.$t('poll_common.votes'), key: "votes"},
        {title: this.$t('poll_common.outcomes'), key: "outcomes"},
      ],
      tags_headers: [
        {title: "Tag", key: "tag"},
        {title: this.$t('poll_meeting_chart_panel.total'), key: "total_count"},
        {title: this.$t('common.threads'), key: "threads_count"},
        {title: this.$t('group_page.polls'), key: "polls_count"},
      ],
      tags_rows: [],
      per_user_headers: [
        {title: "User", key: "user"},
        {title: this.$t('report.country'), key: "country"},
        {title: this.$t('common.threads'), key: "threads"},
        {title: this.$t('navbar.search.comments'), key: "comments"},
        {title: this.$t('group_page.polls'), key: "polls"},
        {title: this.$t('poll_common.votes'), key: "votes"},
        {title: this.$t('poll_common.outcomes'), key: "outcomes"},
        {title: "Reactions", key: "reactions"},
      ],
      per_user_rows: [],
      users_per_country_rows: [],
      users_per_country_headers: [
        {title: this.$t('report.country'), key: 'country'},
        {title: this.$t('report.users'), key: 'users'},
      ],
      per_country_rows: [],
      per_country_headers: [
        {title: 'Country', key: 'country' },
        {title: this.$t('common.threads'), key: "threads"},
        {title: this.$t('navbar.search.comments'), key: "comments"},
        {title: this.$t('group_page.polls'), key: "polls"},
        {title: this.$t('poll_common.votes'), key: "votes"},
        {title: this.$t('poll_common.outcomes'), key: "outcomes"},
        {title: "Reactions", key: "reactions"},
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
      const query = new URLSearchParams({
        interval: this.interval,
        start_month: this.start_month,
        end_month: this.end_month,
        group_ids: this.group_ids.join(',')}).toString()
      fetch('/api/v1/reports?'+query).then(response => {
        response.json().then(data => {
          this.firstYear = data.first_year;
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
          }

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
    h1.text-headline-large.mb-8(v-t="'group_page.participation_report'")

    v-select(
      :label="$t('common.groups')"
      v-model="group_ids"
      :items="all_groups"
      item-title="name"
      item-value="id"
      multiple
      small-chips
      @blur="fetch()"
    )

    .d-flex
      v-select(
        :label="$t('report.start_on')"
        :prepend-icon="mdiCalendar"
        v-model="start_month"
        :items="startMonths"
      )

      v-select(
        :label="$t('report.end_on')"
        :prepend-icon="mdiCalendar"
        v-model="end_month"
        :items="endMonths"
      )

      v-select.ml-8(
        :label="$t('report.interval')"
        v-model="interval"
        :items="intervalItems"
      )


    .d-flex.justify-center
      v-progress-circular(indeterminate color="primary" v-if="loading")

    div(v-if="!loading")

      v-table.mt-8
        thead
          th.pt-4(v-t="'report.total_users'")
          th.pt-4(v-t="'report.total_discussions'")
          th.pt-4(v-t="'report.total_polls'")
          th.pt-4(v-t="'report.discussions_with_polls'")
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
          density="compact"
          :headers="models_per_interval_headers"
          :items="models_per_interval"
        )

      v-card.mt-8
        v-card-title(v-t="'loomio_tags.tags'")
        v-data-table(
          density="compact"
          :headers="tags_headers"
          :items="tags_rows"
        )

      v-card.mt-8
        v-card-title(v-t="'report.actions_per_user'")
        v-data-table(
          density="compact"
          :headers="per_user_headers"
          :items="per_user_rows"
        )

      v-card.mt-8
        v-card-title(v-t="'report.users_per_country'")
        p.px-4.text-body-small(v-t="'report.country_disclaimer'")
        v-data-table(
          density="compact"
          :headers="users_per_country_headers"
          :items="users_per_country_rows"
        )

      v-card.mt-8
        v-card-title(v-t="'report.actions_per_country'")
        v-data-table(
          density="compact"
          :headers="per_country_headers"
          :items="per_country_rows"
        )

</template>
