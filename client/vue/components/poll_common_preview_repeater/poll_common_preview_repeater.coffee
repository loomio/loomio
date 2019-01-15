module.exports =
  props:
    pollsPage: Object
    displayGroupName: Boolean
  computed:
    orderedPolls: ->
      _.sortBy(@pollsPage.pollCollection.polls(), @pollsPage.pollImportance)
  template:
    """
    <div>
      {{ orderedPolls }}
      <poll-common-preview
        v-for="poll in orderedPolls"
        :key="poll.id"
        :poll="poll"
        :display-group-name="displayGroupName"
      ></poll-common-preview>
    </div>
    """
