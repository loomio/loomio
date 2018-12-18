module.exports =
  props:
    stanceCounts: Array
    myStance: Object
  template: """
    <div class="poll-proposal-chart-preview">
      <poll-proposal-chart
        :stance-counts="stanceCounts"
        :diameter="50"
        class="poll-common-collapsed__pie-chart"
      ></poll-proposal-chart>
      <div class="poll-proposal-chart-preview__stance-container">
        <div
          v-if="this.myStance"
          :class="`poll-proposal-chart-preview__stance poll-proposal-chart-preview__stance--${this.myStance.pollOption().name}`"
        ></div>
        <div
          v-if="!this.myStance"
          class="poll-proposal-chart-preview__stance poll-proposal-chart-preview__stance--undecided"
        >?</div>
      </div>
    </div>
  """
