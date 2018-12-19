module.exports =
  props:
    discussion: Object
  template:
    """
    <div class="thread-card lmo-column-left lmo-card--no-padding">
      <context-panel :discussion="discussion"></context-panel>
      <!-- <activity-card discussion="discussion" v-if="discussion.createdEvent()"></activity-card> -->
    </div>
    """
