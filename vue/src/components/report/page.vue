<script lang="js">
import Session            from '@/shared/services/session';
import { mdiCalendar } from '@mdi/js';

import BarChart from '@/components/report/bar_chart';

const sumValues = obj => Object.values(obj).reduce((a, b) => a + b, 0);

function parseGroupIds(ids) {
  return (ids || '').split(',').map(id => parseInt(id)).filter(id => Number.isFinite(id));
}

function downloadCsv(headers, rows, filename) {
  const headerRow = headers.map(h => h.title).join(',');
  const keys = headers.map(h => h.key);
  const dataRows = rows.map(row => keys.map(k => {
    const val = row[k];
    if (typeof val === 'string' && (val.includes(',') || val.includes('"') || val.includes('\n'))) {
      return '"' + val.replace(/"/g, '""') + '"';
    }
    return val ?? '';
  }).join(','));
  const csv = [headerRow, ...dataRows].join('\n');
  const blob = new Blob([csv], { type: 'text/csv' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  a.click();
  URL.revokeObjectURL(url);
}

export default {
  components: {BarChart},
  computed: {
    availableTagNames() {
      if (!this.report_data) return [];
      return this.report_data.tag_names;
    },
    visibleTagThreadsByUserHeaders() {
      return this.tag_threads_by_user_headers.filter(h =>
        h.key === 'user' || this.visible_tags.includes(h.title)
      );
    },
    tagChartData() {
      if (!this.report_data) return { labels: [], datasets: [] };
      const TAG_COLORS = [
        '#2196F3','#E91E63','#4CAF50','#FF9800','#9C27B0',
        '#00BCD4','#FF5722','#009688','#3F51B5','#F44336',
        '#CDDC39','#795548','#FFC107','#8BC34A','#607D8B',
      ];
      const data = this.report_data;
      const allTagCounts = data.tag_counts_per_interval || {};
      const topTags = data.tag_names
        .map(tag => ({ tag, total: Object.values(allTagCounts[tag] || {}).reduce((s, v) => s + parseInt(v), 0) }))
        .filter(t => t.total > 0 && this.visible_tags.includes(t.tag))
        .sort((a, b) => b.total - a.total)
        .slice(0, 15)
        .map(t => t.tag);
      return {
        labels: data.intervals,
        datasets: topTags.map((tag, i) => ({
          label: tag,
          backgroundColor: TAG_COLORS[i % TAG_COLORS.length],
          data: data.intervals.map(interval => parseInt(allTagCounts[tag]?.[interval] || 0)),
        })),
      };
    },
    startMonths() {
      let months = [];
      let next = null;
      for (let year = this.firstYear; year <= new Date().getFullYear(); year++) {
        for (let month = 1; month <= 12; month++) {
          next = year+"-"+String(month).padStart(2, '0');
          months.push(next);
          if (next > new Date().toISOString().slice(0,7)) {
            return months.reverse();
          }
        }
      }
      return months.reverse();
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
            return months.reverse();
          }
        }
      }
      return months.reverse();
    },
    groupScopeItems() {
      const items = [
        {title: this.$t('sidebar.my_groups'), value: 'my'},
        {title: this.$t('report.custom_selection'), value: 'custom'}
      ];
      if (this.current_user_is_admin) {
        items.unshift({title: this.$t('sidebar.all_groups'), value: 'all'});
      }
      return items;
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
      group_scope: this.$route.query['group_scope'] || (this.$route.query['group_ids'] ? 'custom' : 'my'),
      group_ids: parseGroupIds(this.$route.query['group_ids']),
      current_user_is_admin: Session.user().isAdmin,

      start_menu: false,
      end_menu: false,
      start_month: (this.$route.query['start_on'] || (new Date(2019,1,1)).toISOString().slice(0,7)),
      end_month: (new Date()).toISOString().slice(0,7),
      interval: 'month',
      report_data: null,
      user_data: null,
      intervalItems: [
        {title: this.$t('report.day'), value: 'day'},
        {title: this.$t('report.week'), value: 'week'},
        {title: this.$t('report.month'), value: 'month'},
        {title: this.$t('report.year'), value: 'year'}
      ],
      total_users: 0,
      topics_count: 0,
      discussion_topics_count: 0,
      poll_topics_count: 0,
      polls_count: 0,
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
        {title:  this.$t('common.threads'), key: "total_count"},
      ],
      tags_rows: [],
      tag_threads_authored_only: false,
      tag_threads_by_user_rows: [],
      tag_threads_by_user_headers: [],
      visible_tags: [],
      user_name_filter: '',
      country_filter: '',
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
    },
    group_scope(val) {
      this.fetch();
    },
    tag_threads_authored_only(val) {
      if (this.user_data) {
        this.setTagThreadsByUserRows({...this.user_data, tag_names: this.report_data?.tag_names || []});
      }
    }
  },
  methods: {
    downloadIntervalCsv() {
      downloadCsv(this.models_per_interval_headers, this.models_per_interval, 'activity_per_interval.csv');
    },
    downloadTagsCsv() {
      downloadCsv(this.tags_headers, this.tags_rows, 'tags.csv');
    },
    downloadTagThreadsByUserCsv() {
      downloadCsv(this.tag_threads_by_user_headers, this.tag_threads_by_user_rows, 'tag_threads_by_user.csv');
    },
    downloadPerUserCsv() {
      downloadCsv(this.per_user_headers, this.per_user_rows, 'activity_per_user.csv');
    },
    downloadUsersPerCountryCsv() {
      downloadCsv(this.users_per_country_headers, this.users_per_country_rows, 'users_per_country.csv');
    },
    downloadPerCountryCsv() {
      downloadCsv(this.per_country_headers, this.per_country_rows, 'activity_per_country.csv');
    },
    setTagThreadsByUserRows(data) {
      if (!data) { return; }
      const counts = this.tag_threads_authored_only ? data.tag_threads_authored_per_user : data.tag_threads_per_user;
      const tag_names = data.tag_names.map(tag => {
        return {
          name: tag,
          total_count: Object.values(counts[tag] || {}).reduce((sum, count) => sum + count, 0)
        };
      }).filter(tag => {
        return tag.total_count > 0;
      }).sort((a, b) => {
        return b.total_count - a.total_count || a.name.localeCompare(b.name);
      }).map(tag => tag.name);

      this.tag_threads_by_user_headers = [
        {title: "User", key: "user"},
        ...tag_names.map((tag, i) => ({title: tag, key: `tag_${i}`}))
      ];

      this.tag_threads_by_user_rows = data.users.map(user => {
        const row = {user: user.name};
        tag_names.forEach((tag, i) => {
          row[`tag_${i}`] = (counts[tag] || {})[user.id] || 0;
        });
        return row;
      });
    },
    buildQuery(extra = {}) {
      const queryParams = {
        group_scope: this.group_scope,
        interval: this.interval,
        start_month: this.start_month,
        end_month: this.end_month,
        group_ids: this.group_ids.join(','),
        ...extra,
      };
      return new URLSearchParams(queryParams).toString();
    },
    applyBaseData(data) {
      this.report_data = data;
      this.visible_tags = data.tag_names.slice();
      this.firstYear = data.first_year;
      this.all_groups = data.all_groups;
      this.group_ids = data.group_ids;
      this.current_user_is_admin = data.current_user_is_admin;

      this.topics_count = data.topics_count;
      this.discussion_topics_count = data.discussion_topics_count;
      this.poll_topics_count = data.poll_topics_count;
      this.polls_count = data.polls_count;
      this.polls_with_outcomes_count = data.polls_with_outcomes_count;

      this.chartData = {
        labels: data.intervals,
        datasets: [
          {
            label: this.$t('common.threads'),
            backgroundColor: '#2196F3',
            data: data.intervals.map(interval => (data.topics_per_interval[interval] || 0))
          },
          {
            label: this.$t('navbar.search.comments'),
            backgroundColor: '#009688',
            data: data.intervals.map(interval => (data.comments_per_interval[interval] || 0))
          },
          {
            label: this.$t('group_page.polls'),
            backgroundColor: '#4CAF50',
            data: data.intervals.map(interval => (data.polls_per_interval[interval] || 0))
          },
          {
            label: this.$t('poll_common.votes'),
            backgroundColor: '#E91E63',
            data: data.intervals.map(interval => (data.stances_per_interval[interval] || 0))
          },
          {
            label: this.$t('poll_common.outcomes'),
            backgroundColor: '#FF9800',
            data: data.intervals.map(interval => (data.outcomes_per_interval[interval] || 0))
          },
        ]
      };

      this.models_per_interval = data.intervals.slice().reverse().map(interval => ({
        date: interval,
        threads: data.topics_per_interval[interval] || 0,
        comments: data.comments_per_interval[interval] || 0,
        polls: data.polls_per_interval[interval] || 0,
        votes: data.stances_per_interval[interval] || 0,
        outcomes: data.outcomes_per_interval[interval] || 0,
      }));

      this.models_per_interval.push({
        date: 'total',
        threads: sumValues(data.topics_per_interval),
        comments: sumValues(data.comments_per_interval),
        polls: sumValues(data.polls_per_interval),
        votes: sumValues(data.stances_per_interval),
        outcomes: sumValues(data.outcomes_per_interval),
      });

      this.tags_rows = data.tag_names.map(tag => ({
        tag: tag,
        total_count: data.tag_counts[tag],
      }));
    },
    applyUserData(data) {
      this.user_data = data;
      this.total_users = data.total_users || this.total_users;
      this.setTagThreadsByUserRows({...data, tag_names: this.report_data?.tag_names || []});
      this.per_user_rows = data.users.map(user => ({
        user: user.name,
        country: user.country,
        threads: data.discussions_per_user[user.id] || 0,
        comments: data.comments_per_user[user.id] || 0,
        polls: data.polls_per_user[user.id] || 0,
        votes: data.stances_per_user[user.id] || 0,
        outcomes: data.outcomes_per_user[user.id] || 0,
        reactions: data.reactions_per_user[user.id] || 0,
      }));
    },
    applyCountryData(data) {
      this.total_users = data.total_users;
      this.users_per_country_rows = data.countries.map(country => ({
        country: country,
        users: data.users_per_country[country],
      }));
      this.per_country_rows = data.countries.map(country => ({
        country: country,
        threads: data.discussions_per_country[country] || 0,
        comments: data.comments_per_country[country] || 0,
        polls: data.polls_per_country[country] || 0,
        votes: data.stances_per_country[country] || 0,
        outcomes: data.outcomes_per_country[country] || 0,
        reactions: data.reactions_per_country[country] || 0,
      }));
    },
    fetch() {
      this.loading = true;
      const baseQuery = this.buildQuery({section: 'base'});
      fetch('/api/v1/reports?' + baseQuery)
        .then(r => r.json())
        .then(data => {
          this.applyBaseData(data);
          this.loading = false;
          const usersQuery = this.buildQuery({section: 'users'});
          const countriesQuery = this.buildQuery({section: 'countries'});
          Promise.all([
            fetch('/api/v1/reports?' + usersQuery).then(r => r.json()),
            fetch('/api/v1/reports?' + countriesQuery).then(r => r.json()),
          ]).then(([userData, countryData]) => {
            this.applyUserData(userData);
            this.applyCountryData(countryData);
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
      v-model="group_scope"
      :items="groupScopeItems"
    )

    v-select(
      v-if="group_scope === 'custom'"
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
          th.pt-4(v-t="'report.total_threads'")
          th.pt-4(v-t="'report.total_discussions'")
          th.pt-4(v-t="'report.total_polls'")
          th.pt-4(v-t="'report.polls_with_outcomes'")
        tbody
          tr
            td.text-center {{total_users}}
            td.text-center {{topics_count}}
            td.text-center {{discussion_topics_count}}
            td.text-center {{polls_count}}
            td.text-center {{polls_with_outcomes_count}}

      bar-chart.mt-8(:chart-data="chartData")

      v-card.mt-8(:title="$t('report.tags_per_interval', {interval: interval})")
        v-select.mx-4.mt-2(
          v-model="visible_tags"
          :label="$t('report.show_tags')"
          :items="availableTagNames"
          multiple
          chips
          closable-chips
          density="compact"
          hide-details
          clearable
        )
        bar-chart.pa-4(
          :chart-data="tagChartData"
          :options="{ scales: { x: { stacked: true }, y: { stacked: true } } }"
          chart-id="tag-chart"
        )

      v-card.mt-8(:title="$t('report.actions_per_interval', {interval: interval})")
        template(v-slot:append)
          v-btn(variant="text" size="small" @click="downloadIntervalCsv")
            span(v-t="'report.download_csv'")
        v-data-table(
          density="compact"
          :headers="models_per_interval_headers"
          :items="models_per_interval"
        )

      v-card.mt-8(:title="$t('loomio_tags.tags')")
        template(v-slot:append)
          v-btn(variant="text" size="small" @click="downloadTagsCsv")
            span(v-t="'report.download_csv'")
        v-data-table(
          density="compact"
          :headers="tags_headers"
          :items="tags_rows"
        )

      v-card.mt-8(:title="$t('report.tag_threads_by_user')")
        template(v-slot:append)
          .d-flex.align-center
            v-switch.mr-4(
              v-model="tag_threads_authored_only"
              color="primary"
              density="compact"
              hide-details
              :label="$t('report.authored_only')"
            )
            v-btn(variant="text" size="small" @click="downloadTagThreadsByUserCsv")
              span(v-t="'report.download_csv'")
        v-text-field.mx-4.mt-2(
          v-model="user_name_filter"
          :label="$t('report.filter_by_name')"
          density="compact"
          hide-details
          clearable
          style="min-width: 256px"
        )
        v-select.mx-4.mt-2.mb-2(
          v-model="visible_tags"
          :label="$t('report.show_tags')"
          :items="availableTagNames"
          multiple
          chips
          closable-chips
          density="compact"
          hide-details
          clearable
        )
        v-data-table(
          density="compact"
          :headers="visibleTagThreadsByUserHeaders"
          :items="tag_threads_by_user_rows"
          :search="user_name_filter"
        )

      v-card.mt-8(:title="$t('report.actions_per_user')")
        template(v-slot:append)
          v-btn(variant="text" size="small" @click="downloadPerUserCsv")
            span(v-t="'report.download_csv'")
        v-text-field.mx-4.mb-2(
          v-model="user_name_filter"
          :label="$t('report.filter_by_name')"
          density="compact"
          hide-details
          clearable
        )
        v-data-table(
          density="compact"
          :headers="per_user_headers"
          :items="per_user_rows"
          :search="user_name_filter"
        )

      v-card.mt-8(:title="$t('report.users_per_country')")
        template(v-slot:append)
          v-btn(variant="text" size="small" @click="downloadUsersPerCountryCsv")
            span(v-t="'report.download_csv'")
        p.px-4.text-body-small(v-t="'report.country_disclaimer'")
        v-text-field.mx-4.mb-2(
          v-model="country_filter"
          :label="$t('report.filter_by_country')"
          density="compact"
          hide-details
          clearable
        )
        v-data-table(
          density="compact"
          :headers="users_per_country_headers"
          :items="users_per_country_rows"
          :search="country_filter"
        )

      v-card.mt-8(:title="$t('report.actions_per_country')")
        template(v-slot:append)
          v-btn(variant="text" size="small" @click="downloadPerCountryCsv")
            span(v-t="'report.download_csv'")
        v-text-field.mx-4.mb-2(
          v-model="country_filter"
          :label="$t('report.filter_by_country')"
          density="compact"
          hide-details
          clearable
        )
        v-data-table(
          density="compact"
          :headers="per_country_headers"
          :items="per_country_rows"
          :search="country_filter"
        )

</template>
