module.exports = Vue.component 'PollProposalChartPreview',
  props:
    stanceCounts: Array
    myStance: Object
  template: """
    <div class="poll-proposal-chart-preview">
      <poll-proposal-chart
        :stance-counts="this.stanceCounts"
        :diameter="50"
        class="poll-common-collapsed__pie-chart"
      ></poll-proposal-chart>
      <!-- <div class="poll-proposal-chart-preview__stance-container">
        <div
          v-if="myStance"
          class="poll-proposal-chart-preview__stance poll-proposal-chart-preview__stance--{{myStance.pollOption().name}}"
        ></div>
        <div
          v-if="!myStance"
          class="poll-proposal-chart-preview__stance poll-proposal-chart-preview__stance--undecided"
        >?</div>
      </div> -->
    </div>
  """
