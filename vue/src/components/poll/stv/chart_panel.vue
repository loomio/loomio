<script lang="js">
import { I18n } from '@/i18n';

export default {
  props: {
    poll: Object
  },

  computed: {
    stvResults() {
      return this.poll.stvResults || {};
    },

    hasResults() {
      return this.stvResults.rounds && this.stvResults.rounds.length > 0;
    },

    elected() {
      return (this.stvResults.elected || []).map(e => ({
        ...e,
        name: e.name,
        roundElected: e.round_elected
      }));
    },

    tied() {
      return (this.stvResults.tied || []).map(e => ({
        ...e,
        name: e.name
      }));
    },

    rounds() {
      return this.stvResults.rounds || [];
    },

    candidates() {
      // All candidate IDs from the first round tallies
      if (!this.rounds.length) return [];
      const firstRound = this.rounds[0];
      return Object.keys(firstRound.tallies || {});
    },

    candidateNames() {
      const names = {};
      this.poll.pollOptions().forEach(po => {
        names[po.id.toString()] = po.name;
      });
      return names;
    },

    electedIds() {
      return new Set((this.stvResults.elected || []).map(e => e.poll_option_id.toString()));
    },

    tiedIds() {
      return new Set((this.stvResults.tied || []).map(e => e.poll_option_id.toString()));
    },

    eliminatedByRound() {
      const map = {};
      this.rounds.forEach(r => {
        (r.eliminated || []).forEach(id => {
          map[id.toString()] = r.round;
        });
      });
      return map;
    },

    electedByRound() {
      const map = {};
      (this.stvResults.elected || []).forEach(e => {
        map[e.poll_option_id.toString()] = e.round_elected;
      });
      return map;
    },

    tiedInRound() {
      const map = {};
      this.rounds.forEach(r => {
        (r.tied || []).forEach(id => {
          map[id.toString()] = r.round;
        });
      });
      return map;
    },

    methodLabel() {
      const method = this.stvResults.method === 'meek'
        ? I18n.global.t('poll_stv_results.method_meek')
        : I18n.global.t('poll_stv_results.method_scottish');
      const quotaType = this.stvResults.quota_type === 'hare'
        ? I18n.global.t('poll_stv_results.quota_hare')
        : I18n.global.t('poll_stv_results.quota_droop');
      const quota = typeof this.stvResults.quota === 'number'
        ? Math.round(this.stvResults.quota * 100) / 100
        : this.stvResults.quota;
      return I18n.global.t('poll_stv_results.quota_info', { method, quota_type: quotaType, quota });
    }
  },

  methods: {
    candidateName(id) {
      return this.candidateNames[id.toString()] || `#${id}`;
    },

    tallyForRound(round, candidateId) {
      const val = (round.tallies || {})[candidateId.toString()];
      if (val === undefined || val === null) return '-';
      return Math.round(val * 100) / 100;
    },

    cellClass(round, candidateId) {
      const cid = candidateId.toString();
      if ((round.elected || []).map(String).includes(cid)) return 'stv-cell-elected';
      if ((round.eliminated || []).map(String).includes(cid)) return 'stv-cell-eliminated';
      if ((round.tied || []).map(String).includes(cid)) return 'stv-cell-tied';
      // Check if already elected or eliminated in a prior round
      if (this.electedByRound[cid] && this.electedByRound[cid] < round.round) return 'stv-cell-inactive';
      if (this.eliminatedByRound[cid] && this.eliminatedByRound[cid] < round.round) return 'stv-cell-inactive';
      return '';
    },

    candidateStatus(candidateId) {
      const cid = candidateId.toString();
      if (this.electedByRound[cid]) {
        return I18n.global.t('poll_stv_results.elected_in_round', { round: this.electedByRound[cid] });
      }
      if (this.eliminatedByRound[cid]) {
        return I18n.global.t('poll_stv_results.eliminated_in_round', { round: this.eliminatedByRound[cid] });
      }
      if (this.tiedInRound[cid]) {
        return I18n.global.t('poll_stv_results.tied_in_round', { round: this.tiedInRound[cid] });
      }
      return '';
    }
  }
};
</script>

<template lang="pug">
.poll-stv-chart-panel
  template(v-if="!hasResults")
    v-alert(density="compact" variant="tonal" type="info")
      span(v-t="'poll_stv_results.results_available_when_closed'")

  template(v-else)
    .text-subtitle-2.mb-2.text-medium-emphasis {{ methodLabel }}

    //- Winners summary
    h3.text-subtitle-1.mb-2(v-t="'poll_stv_results.elected'")
    v-chip.mr-2.mb-2(
      v-for="winner in elected"
      :key="winner.poll_option_id"
      color="success"
      variant="tonal"
    )
      v-icon.mr-1(icon="mdi-check-circle" size="small")
      | {{ winner.name }}
    span.text-medium-emphasis(v-if="!elected.length") {{ $t('poll_stv_results.no_candidates_elected') }}

    //- Tied candidates summary
    template(v-if="tied.length")
      h3.text-subtitle-1.mb-2.mt-4(v-t="'poll_stv_results.tied'")
      v-chip.mr-2.mb-2(
        v-for="candidate in tied"
        :key="candidate.poll_option_id"
        color="warning"
        variant="tonal"
      )
        v-icon.mr-1(icon="mdi-approximately-equal" size="small")
        | {{ candidate.name }}

    //- Round-by-round table
    v-table.mt-4(density="compact")
      thead
        tr
          th(v-t="'poll_stv_results.round'", :args="{number: ''}")
          th(v-for="cid in candidates" :key="cid")
            .d-flex.flex-column.align-center
              span {{ candidateName(cid) }}
              v-chip.mt-1(
                v-if="electedIds.has(cid)"
                color="success"
                size="x-small"
                variant="flat"
              ) {{ $t('poll_stv_results.elected') }}
              v-chip.mt-1(
                v-else-if="tiedIds.has(cid)"
                color="warning"
                size="x-small"
                variant="flat"
              ) {{ $t('poll_stv_results.tied') }}
      tbody
        tr(v-for="round in rounds" :key="round.round")
          td
            strong {{ $t('poll_stv_results.round', { number: round.round }) }}
          td.text-center(
            v-for="cid in candidates"
            :key="cid"
            :class="cellClass(round, cid)"
          )
            | {{ tallyForRound(round, cid) }}
</template>

<style lang="sass">
.stv-cell-elected
  background-color: rgba(76, 175, 80, 0.15)
  font-weight: bold

.stv-cell-eliminated
  background-color: rgba(244, 67, 54, 0.1)
  text-decoration: line-through

.stv-cell-tied
  background-color: rgba(255, 152, 0, 0.15)
  font-weight: bold

.stv-cell-inactive
  color: rgba(0, 0, 0, 0.3)
</style>
