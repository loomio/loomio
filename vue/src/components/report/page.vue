<script lang="js">
import AppConfig          from '@/shared/services/app_config';
import Records            from '@/shared/services/records';
import Session            from '@/shared/services/session';
import {subMonths, startOfMonth } from 'date-fns';

import BarChart from '@/components/report/bar_chart';

const sumValues = obj => Object.values(obj).reduce((a, b) => a + b, 0);


export default {
  components: {BarChart},
  data() {
    return {
      chartData: {
        labels: [],
        datasets: []
      },
      group_ids: this.$route.query['group_ids'].split(',').map(id => parseInt(id)),
      start_menu: false,
      end_menu: false,
      start_month: (new Date(2019,1,1)).toISOString().slice(0,7),
      end_month: (new Date()).toISOString().slice(0,7),
      interval: 'month',
      total_users: 0,
      discussions_count: 0,
      polls_count: 0,
      discussions_with_polls_count: 0,
      polls_with_outcomes_count: 0,
      models_per_interval: [],
      models_per_interval_headers: [
        {text: "Date", value: "date"},
        {text: "Threads", value: "threads"},
        {text: "Comments", value: "comments"},
        {text: "Polls", value: "polls"},
        {text: "Votes", value: "votes"},
        {text: "Outcomes", value: "outcomes"},
      ],
      tags_headers: [
        {text: "Tag", value: "tag"},
        {text: "Total count", value: "total_count"},
        {text: "Threads count", value: "threads_count"},
        {text: "Polls count", value: "polls_count"},
      ],
      tags_rows: [],
      per_user_headers: [
        {text: "User", value: "user"},
        {text: "Threads", value: "threads"},
        {text: "Comments", value: "comments"},
        {text: "Polls", value: "polls"},
        {text: "Votes", value: "votes"},
        {text: "Outcomes", value: "outcomes"},
        {text: "Reactions", value: "reactions"},
      ],
      per_user_rows: [],
      users_per_country_rows: [],
      users_per_country_headers: [
        {text: 'Country', value: 'country'},
        {text: 'Users', value: 'users'},
      ],
      per_country_rows: [],
      per_country_headers: [
        {text: 'Country', value: 'country' },
        {text: "Threads", value: "threads"},
        {text: "Comments", value: "comments"},
        {text: "Polls", value: "polls"},
        {text: "Votes", value: "votes"},
        {text: "Outcomes", value: "outcomes"},
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
      const query = new URLSearchParams({interval: this.interval, start_month: this.start_month, end_month: this.end_month, group_ids: this.group_ids.join(',')}).toString()
      fetch('/api/v1/reports?'+query).then(response => {
        response.json().then(data => {
          this.total_users = data.total_users;
          this.discussions_count = data.discussions_count;
          this.polls_count = data.polls_count;
          this.discussions_with_polls_count = data.discussions_with_polls_count;
          this.polls_with_outcomes_count = data.polls_with_outcomes_count;

          this.chartData = {
            labels: data.intervals,
            datasets: [
              {
                label: 'Threads',
                backgroundColor: '#2196F3',
                data: data.intervals.map(interval => (data.discussions_per_interval[interval] || 0) )
              },
              {
                label: 'Comments',
                backgroundColor: '#009688',
                data: data.intervals.map(interval => (data.comments_per_interval[interval] || 0) )
              },
              {
                label: 'Polls',
                backgroundColor: '#4CAF50',
                data: data.intervals.map(interval => (data.polls_per_interval[interval] || 0) )
              },
              {
                label: 'Votes',
                backgroundColor: '#E91E63',
                data: data.intervals.map(interval => (data.stances_per_interval[interval] || 0) )
              },
              {
                label: 'Outcomes',
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
    h1.text-h4(v-t="'group_page.participation_report'")

    p group ids {{group_ids}}

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
            label="Start on"
            prepend-icon="mdi-calendar"
            readonly
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
            label="End on"
            prepend-icon="mdi-calendar"
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
        label="Interval"
        v-model="interval"
        :items=['day', 'week', 'month']
      )

    p Threads {{discussions_count}}
    p Polls {{polls_count}}
    p Threads with polls {{discussions_with_polls_count}}
    p Polls with outcomes {{polls_with_outcomes_count}}

    bar-chart(:chart-data="chartData")
    p Records per {{interval}}
    v-data-table(
      dense
      disable-pagination
      hide-default-footer
      :headers="models_per_interval_headers"
      :items="models_per_interval"
    )

    p Tags
    v-data-table(
      dense
      disable-pagination
      hide-default-footer
      :headers="tags_headers"
      :items="tags_rows"
    )

    p Participation by user
    v-data-table(
      dense
      disable-pagination
      hide-default-footer
      :headers="per_user_headers"
      :items="per_user_rows"
      :items-per-page="50"
    )

    p Users per country
    v-data-table(
      dense
      disable-pagination
      hide-default-footer
      :headers="users_per_country_headers"
      :items="users_per_country_rows"
    )
    p Total users {{total_users}}

    p Participation by country
    v-data-table(
      dense
      disable-pagination
      hide-default-footer
      :headers="per_country_headers"
      :items="per_country_rows"
    )

</template>
