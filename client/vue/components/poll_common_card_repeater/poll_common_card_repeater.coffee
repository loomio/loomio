module.exports =
  props:
    discussion: Object
  template:
    """
    <div>
      <poll-common-card
        v-for="poll in discussion.activePolls()"
        :key="poll.id"
        :poll="poll"
        class="lmo-card--no-padding lmo-column-right"
      ></poll-common-card>
    </div>
    """
