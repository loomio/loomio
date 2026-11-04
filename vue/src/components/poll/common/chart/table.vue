<script lang="js">
import Records from '@/shared/services/records';
import BarIcon from '@/components/poll/common/icon/bar.vue';
import PieIcon from '@/components/poll/common/icon/pie.vue';
import GridIcon from '@/components/poll/common/icon/grid.vue';
import WatchRecords from '@/mixins/watch_records';
import { useI18n } from 'vue-i18n';
import { VAvatarGroup } from 'vuetify/components/VAvatarGroup';

const METRIC_COLUMNS = ['target_percent', 'score_percent', 'votes_cast_percent', 'voter_percent', 'score', 'unweighted_score', 'average', 'votes', 'vote_count'];
// Show five identities, with overflow based on the full count rather than the
// bounded sample of voter identities supplied in a result row.
const VOTER_AVATARS_MAX = 5;

export default {
  setup() {
    const { t } = useI18n();
    return { t, METRIC_COLUMNS, VOTER_AVATARS_MAX };
  },
  mixins: [WatchRecords],
  components: {BarIcon, PieIcon, GridIcon, VAvatarGroup},
  props: {
    poll: Object,
    hideVoters: Boolean
  },
  emits: ['metric-change'],

  data() {
    return {
      users: {},
      selectedMetric: this.defaultChartMetric(),
      slices: [],
    };
  },

  methods: {
    defaultChartMetric() {
      const columns = this.poll.resultColumns;
      if (this.poll.chartColumn === 'target_percent' && columns.includes('target_percent')) return 'target_percent';
      if (this.poll.chartColumn === 'voter_percent' && columns.includes('voter_percent')) return 'voter_percent';
      if (this.poll.chartColumn === 'score_percent') {
        if (columns.includes('votes_cast_percent')) return 'votes_cast_percent';
        if (columns.includes('score_percent')) return 'score_percent';
        if (columns.includes('score') && this.poll.chartType === 'pie') return 'score';
      }
      if (this.poll.chartColumn === 'max_score_percent' && columns.includes('score')) return 'score';
      return null;
    },
    chartableMetric(column) {
      if (!METRIC_COLUMNS.includes(column)) return false;
      if (this.poll.chartType === 'pie' && !this.poll.singleChoice() && ['voter_percent', 'votes', 'vote_count'].includes(column)) return false;
      return true;
    },
    selectMetric(column) {
      this.selectedMetric = column;
      this.updateSlices();
    },
    updateSlices() {
      if (this.poll.chartType !== 'pie') return;
      if (!this.selectedMetric) {
        this.slices = this.poll.pieSlices();
        return;
      }
      const countMetric = ['votes', 'vote_count'].includes(this.selectedMetric);
      const scoreMetric = ['score', 'unweighted_score'].includes(this.selectedMetric);
      const totalScore = scoreMetric ? this.poll.results.reduce((sum, option) => sum + Number(option[this.selectedMetric]), 0) : 0;
      this.slices = this.poll.results.map(option => ({
        color: option.color,
        value: scoreMetric
          ? (totalScore ? Number(option[this.selectedMetric]) / totalScore * 100 : 0)
          : (countMetric ? this.voterCountPercent(option) : Number(option[this.selectedMetric === 'voter_percent' ? 'voter_percent' : 'score_percent'] || 0))
      })).filter(slice => slice.value > 0);
    },
    barPercent(option) {
      const metric = this.selectedMetric;
      if (!metric) return this.clampPercent(option[this.poll.chartColumn]);
      if (metric === 'votes' || metric === 'vote_count') return this.clampPercent(this.voterCountPercent(option));
      if (metric === 'votes_cast_percent') return this.clampPercent(option.score_percent);
      if (metric === 'score' || metric === 'unweighted_score') {
        const maximum = Math.max(...this.poll.results.map(result => Number(result[metric] || 0)), 0);
        return maximum ? this.clampPercent(Number(option[metric] || 0) / maximum * 100) : 0;
      }
      if (metric === 'average') {
        const maximum = Number(this.poll.defaulted('scoreMax'));
        return maximum ? this.clampPercent(Number(option.average || 0) / maximum * 100) : 0;
      }
      return this.clampPercent(option[metric]);
    },
    realOption(opt) {
      return Records.pollOptions.find(opt.id) || {meaning: '', name: opt.name}
    },
    voterCountPercent(option) {
      return this.poll.voteCountEligible > 0 ? option.vote_count / this.poll.voteCountEligible * 100 : 0;
    },
    voterOverflowText(option) {
      const visible = Math.min(option.voter_ids.length, VOTER_AVATARS_MAX);
      const overflow = option.vote_count - visible;
      return overflow > 0 ? `+${overflow}` : '';
    },
    clampPercent(num) { return Math.max(0, Math.min(num, 100)); }
  },

  watch: {
    selectedMetric: {
      immediate: true,
      handler(metric) { this.$emit('metric-change', metric); }
    },
    // A poll reload or weights toggle can remove the selected measure's column.
    'poll.resultColumns'(columns) {
      if (this.selectedMetric && !columns.includes(this.selectedMetric)) {
        this.selectedMetric = this.defaultChartMetric();
        this.updateSlices();
      }
    }
  },

  created() {
    this.updateSlices();
    this.watchRecords({
      collections: ['users', 'stances', 'polls'],
      query: () => {
        this.updateSlices();
        this.poll.results.forEach(option => {
          option.voter_ids.forEach(id => {
            let user;
            if ((user = Records.users.find(id))) {
              this.users[id] = user
            }
          });
        });
      }
    });
  }
};

</script>

<template lang="pug">
.poll-common-chart-table
  v-table(density="comfortable")
    thead
      tr
        template(v-for="col in poll.resultColumns")
          th.text-left.d-none.d-sm-table-cell(v-if="col == 'chart'") {{ t(poll.closedAt ? 'poll_common.results' : 'poll_common.current_results') }}
          th.text-left(v-if="col == 'name'") {{ t(poll.resultHeadingKeys.name) }}
          th.text-right(v-if="col == 'rank'") {{ t(poll.resultHeadingKeys.rank) }}
          th.text-right(v-if="METRIC_COLUMNS.includes(col)")
            button.poll-common-chart-table__metric(type="button" :aria-pressed="selectedMetric === col" :disabled="!chartableMetric(col)" @click="selectMetric(col)") {{ t(poll.resultHeadingKeys[col]) }}
          th.d-none.d-sm-table-cell(v-if="col == 'voters' && !hideVoters")
    tbody
      tr(v-for="option, index in poll.results", :key="option.id")
        template(v-for="col in poll.resultColumns")
          td.pa-2.d-none.d-sm-table-cell(
            v-if="col == 'chart' && poll.chartType == 'pie' && index == 0"
            style="vertical-align: top"
            :rowspan="poll.results.length"
          )
            pie-icon.ma-2(:slices="slices", :size='128')
          td.pr-2.py-2.d-none.d-sm-table-cell(
            v-if="col == 'chart' && poll.chartType == 'bar'"
            style="width: 128px; min-width: 128px; padding: 0 8px 0 0"
          )
            div.rounded.bg-info(:style="{width: barPercent(option)+'%', height: '24px'}")
          td(v-if="col == 'name' " :class="{'text-no-wrap': option.id === -1}" :style="poll.chartType == 'pie' ? {'border-left': '4px solid ' + option.color} : {}")
            template(v-if="realOption(option).meaning")
              v-tooltip(right)
                template(v-slot:activator="{ props }")
                  span(v-bind="props")
                    plain-text(v-if="option.name_format == 'plain'" :model="realOption(option)" field="name")
                    span(v-if="option.name_format == 'i18n'" v-t="option.name")
                span
                  plain-text(:model="realOption(option)" field="meaning")
            template(v-else)
              plain-text(v-if="option.name_format == 'plain'" :model="realOption(option)" field="name")
              span(v-if="option.name_format == 'i18n'" v-t="option.name")
          td.text-right(v-if="col == 'target_percent' && option.icon == 'agree'") {{option.target_percent.toFixed(0)}}%
          td.text-right(v-if="col == 'target_percent' && option.icon != 'agree'")
          td.text-right(v-if="col == 'rank'") {{option.rank}}
          td.text-right(v-if="col == 'score'") {{ option.score }}
          td.text-right(v-if="col == 'unweighted_score'") {{option.unweighted_score}}
          td.text-right(v-if="col == 'votes' || col == 'vote_count'") {{option.vote_count}}
          td.text-right(v-if="col == 'average'") {{option.average}}
          td.text-right(v-if="col == 'voter_percent'") {{option.voter_percent.toFixed(0)}}%
          td.text-right(v-if="col == 'score_percent' || col == 'votes_cast_percent'") {{option.score_percent === null ? '' : option.score_percent.toFixed(0) + "%"}}
          td.text-right.d-none.d-sm-table-cell(v-if="col == 'voters' && !hideVoters")
            v-avatar-group(
              :items="option.voter_ids.slice(0, VOTER_AVATARS_MAX).map(id => ({ id }))"
              :overflow-text="voterOverflowText(option)"
              :size="24"
              :gap="-6"
              border
            )
              template(v-slot:item="{ props }")
                user-avatar(:key="props.id" :user="users[props.id]" :size="24" no-link)
</template>
<style>
.v-data-table tbody tr:hover {
  background: none !important;
}

.poll-common-chart-table table {
  width: 100%;
}

.poll-common-chart-table__metric {
  background: none;
  border: 0;
  border-bottom: 2px solid transparent;
  color: inherit;
  cursor: pointer;
  font: inherit;
  padding: 0 0 2px;
  text-align: right;
}

.poll-common-chart-table__metric:hover,
.poll-common-chart-table__metric:focus-visible,
.poll-common-chart-table__metric[aria-pressed="true"] {
  border-bottom-color: currentColor;
}

.poll-common-chart-table__metric:disabled {
  border-bottom-color: transparent;
  cursor: default;
}
</style>
