module.exports =
  props:
    poll: Object
  template:
    """
    <div v-if="poll.membersCount() > 0" class="poll-common-percent-voted lmo-hint-text">
      <span v-t="{ path: 'poll_common_percent_voted.sentence', args: { numerator: poll.stancesCount, denominator: poll.membersCount(), percent: poll.percentVoted() } }"></span>
    </div>
    """
