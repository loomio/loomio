<script lang="js">
import Records from '@/shared/services/records';
import BarIcon from '@/components/poll/common/icon/bar.vue';
import PieIcon from '@/components/poll/common/icon/pie.vue';
import GridIcon from '@/components/poll/common/icon/grid.vue';
import WatchRecords from '@/mixins/watch_records';

export default {
  mixins: [WatchRecords],
  components: {BarIcon, PieIcon, GridIcon},
  props: {
    poll: Object
  },

  data() {
    return {
      users: {},
      slices: this.poll.pieSlices(),
    };
  },

  methods: {
    optionMeaning(id) {
      return (Records.pollOptions.find(id) || {}).meaning
    },
    clampPercent(num) { return Math.max(0, Math.min(num, 100)); }
  },

  created() {
    this.watchRecords({
      collections: ['users', 'stances', 'polls'],
      query: () => {
        this.slices = this.poll.pieSlices();
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
          th.text-left(v-if="col == 'chart'" v-t="poll.closedAt ? 'poll_common.results' : 'poll_common.current_results'")
          th.text-left(v-if="col == 'name'" v-t='"common.option"')
          th.text-right(v-if="col == 'target_percent'" v-t='"poll_count_form.pct_of_target"')
          th.text-right(v-if="col == 'score_percent'" v-t='"poll_ranked_choice_form.pct_of_points"')
          th.text-right(v-if="col == 'voter_percent'" v-t='"poll_ranked_choice_form.pct_of_voters"')
          th.text-right(v-if="col == 'score'" v-t='"poll_ranked_choice_form.points"')
          th.text-right(v-if="col == 'rank'" v-t='"poll_ranked_choice_form.rank"')
          th.text-right(v-if="col == 'average'" v-t='"poll_ranked_choice_form.mean"')
          th.text-right(v-if="col == 'voter_count'" v-t='"membership_card.voters"')
          th(v-if="col == 'voters'")
    tbody
      tr(v-for="option, index in poll.results", :key="option.id")
        template(v-for="col in poll.resultColumns")
          td.pa-0(
            v-if="col == 'chart' && poll.chartType == 'pie' && index == 0"
            style="vertical-align: top"
            :rowspan="poll.results.length"
          )
            pie-icon.ma-2(:slices="slices", :size='128')
          td.pr-2.py-2(
            v-if="col == 'chart' && poll.chartType == 'bar'"
            style="width: 128px; min-width: 128px; padding: 0 8px 0 0"
          )
            div.rounded(:style="{width: clampPercent(option[poll.chartColumn])+'%', height: '24px', 'background-color': option.color}")
          td(v-if="col == 'name' " :style="poll.chartType == 'pie' ? {'border-left': '4px solid ' + option.color} : {}")
            template(v-if="optionMeaning(option.id)")
              v-tooltip(right)
                template(v-slot:activator="{ props }")
                  span(v-bind="props")
                    span(v-if="option.name_format == 'plain'") {{option.name}}
                    span(v-if="option.name_format == 'i18n'" v-t="option.name")
                span {{optionMeaning(option.id)}}
            template(v-else)
              span(v-if="option.name_format == 'plain'") {{option.name}}
              span(v-if="option.name_format == 'i18n'" v-t="option.name")
            // poll-meeting-time(:name='option.name')
          td.text-right(v-if="col == 'target_percent' && option.icon == 'agree'") {{option.target_percent.toFixed(0)}}%
          td.text-right(v-if="col == 'target_percent' && option.icon != 'agree'")
          td.text-right(v-if="col == 'rank'") {{option.rank}}
          td.text-right(v-if="col == 'score'") {{option.score}}
          td.text-right(v-if="col == 'voter_count'") {{option.voter_count}}
          td.text-right(v-if="col == 'average'") {{Math.round((option.average + Number.EPSILON) * 100) / 100}}
          td.text-right(v-if="col == 'voter_percent'") {{option.voter_percent.toFixed(0)}}%
          td.text-right(v-if="col == 'score_percent'") {{option.score_percent.toFixed(0)}}%
          td.text-right(v-if="col == 'voters'")
            div.poll-common-chart-table__voter-avatars
              user-avatar.float-left(v-for="id in option.voter_ids", :key="id", :user="users[id]", :size="24" no-link)
</template>
<style lang="sass">
.v-data-table > .v-data-table__wrapper > table > tbody > tr:hover:not(.v-data-table__expanded__content):not(.v-data-table__empty-wrapper)
  background: none !important

.poll-common-chart-table
  table
    width: 100%

.poll-common-chart-table__voter-avatars
  position: relative
  max-height: 72px
  overflow: hidden

.poll-common-chart-table__voter-avatars:hover
  max-height: none
  overflow: show

</style>
