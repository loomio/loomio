<script lang="js">
import Records from '@/shared/services/records';
import BarIcon from '@/components/poll/common/icon/bar.vue';
import PieIcon from '@/components/poll/common/icon/pie.vue';
import GridIcon from '@/components/poll/common/icon/grid.vue';
import Vue from 'vue';

export default {
  components: {BarIcon, PieIcon, GridIcon},
  props: {
    poll: Object
  },

  data() {
    return {
      users: {},
      slices: []
    };
  },

  watch: {
    'poll.stanceCounts'() { this.slices = this.poll.pieSlices(); }
  },
  
  methods: {
    optionMeaning(id) {
      return Records.pollOptions.find(id).meaning
    },
    clampPercent(num) { return Math.max(0, Math.min(num, 100)); }
  },

  created() {
    this.watchRecords({
      collections: ['users', 'stances'],
      query: () => {
        this.poll.results.forEach(option => {
          option.voter_ids.forEach(id => {
            let user;
            if ((user = Records.users.find(id))) {
              Vue.set(this.users, id, user);
            } else {
              Records.users.addMissing(id);
            }
          });
        });
      }
    });
  }
};

</script>

<template>

<div class="poll-common-chart-table">
  <v-simple-table dense="dense">
    <thead>
      <tr>
        <template v-for="col in poll.resultColumns">
          <th class="text-left" v-if="col == 'chart'"></th>
          <th class="text-left" v-if="col == 'name'" v-t="'common.option'"></th>
          <th class="text-right" v-if="col == 'target_percent'" v-t="'poll_count_form.pct_of_target'"></th>
          <th class="text-right" v-if="col == 'score_percent'" v-t="'poll_ranked_choice_form.pct_of_points'"></th>
          <th class="text-right" v-if="col == 'voter_percent'" v-t="'poll_ranked_choice_form.pct_of_voters'"></th>
          <th class="text-right" v-if="col == 'score'" v-t="'poll_ranked_choice_form.points'"></th>
          <th class="text-right" v-if="col == 'rank'" v-t="'poll_ranked_choice_form.rank'"></th>
          <th class="text-right" v-if="col == 'average'" v-t="'poll_ranked_choice_form.mean'"></th>
          <th class="text-right" v-if="col == 'voter_count'" v-t="'membership_card.voters'"></th>
          <th v-if="col == 'voters'"></th>
        </template>
      </tr>
    </thead>
    <tbody>
      <tr v-for="option, index in poll.results" :key="option.id">
        <template v-for="col in poll.resultColumns">
          <td class="pa-0" v-if="col == 'chart' && poll.chartType == 'pie' && index == 0" style="vertical-align: top" :rowspan="poll.results.length"> 
            <pie-icon class="ma-2" :slices="slices" :size="128"></pie-icon>
          </td>
          <td class="pr-2 py-2" v-if="col == 'chart' && poll.chartType == 'bar'" style="width: 128px; min-width: 128px; padding: 0 8px 0 0">
            <div class="rounded" :style="{width: clampPercent(option[poll.chartColumn])+'%', height: '24px', 'background-color': option.color}"></div>
          </td>
          <td v-if="col == 'name' " :style="poll.chartType == 'pie' ? {'border-left': '4px solid ' + option.color} : {}">
            <template v-if="option.id && optionMeaning(option.id)">
              <v-tooltip right="right">
                <template v-slot:activator="{ on, attrs }"><span v-bind="attrs" v-on="on"><span v-if="option.name_format == 'plain'">{{option.name}}</span><span v-if="option.name_format == 'i18n'" v-t="option.name"></span></span></template><span>{{optionMeaning(option.id)}}</span>
              </v-tooltip>
            </template>
            <template v-else><span v-if="option.name_format == 'plain'">{{option.name}}</span><span v-if="option.name_format == 'i18n'" v-t="option.name"></span></template>
            <!-- poll-meeting-time(:name='option.name')-->
          </td>
          <td class="text-right" v-if="col == 'target_percent' && option.icon == 'agree'">{{option.target_percent.toFixed(0)}}%</td>
          <td class="text-right" v-if="col == 'target_percent' && option.icon != 'agree'"></td>
          <td class="text-right" v-if="col == 'rank'">{{option.rank}}</td>
          <td class="text-right" v-if="col == 'score'">{{option.score}}</td>
          <td class="text-right" v-if="col == 'voter_count'">{{option.voter_count}}</td>
          <td class="text-right" v-if="col == 'average'">{{Math.round((option.average + Number.EPSILON) * 100) / 100}}</td>
          <td class="text-right" v-if="col == 'voter_percent'">{{option.voter_percent.toFixed(0)}}%</td>
          <td class="text-right" v-if="col == 'score_percent'">{{option.score_percent.toFixed(0)}}%</td>
          <td class="text-right" v-if="col == 'voters'">
            <div class="poll-common-chart-table__voter-avatars">
              <user-avatar class="float-left" v-for="id in option.voter_ids" :key="id" :user="users[id]" :size="24" no-link="no-link"></user-avatar>
            </div>
          </td>
        </template>
      </tr>
    </tbody>
  </v-simple-table>
</div>
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
