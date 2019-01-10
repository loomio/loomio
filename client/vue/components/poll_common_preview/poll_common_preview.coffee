Session       = require 'shared/services/session'
LmoUrlService = require 'shared/services/lmo_url_service'

module.exports =
  props:
    poll: Object
    displayGroupName: String
  methods:
    urlFor: (model) -> LmoUrlService.route(model: model)
    showGroupName: ->
      @displayGroupName && @poll.group()
  template:
    """
    <a :href="urlFor(poll)" class="poll-common-preview">
      <poll-common-chart-preview :poll="poll"></poll-common-chart-preview>
      <div class="poll-common-preview__body">
        <div class="md-subhead lmo-truncate-text">
          <span>{{poll.title}}</span>
        </div>
        <div class="md-caption lmo-grey-on-white lmo-truncate-text">
          <span v-if="showGroupName()">{{ poll.group().fullName }}</span>
          <span v-if="!showGroupName()" v-t="{ path: 'poll_common_collapsed.by_who', args: { name: poll.authorName() } }"></span>
          <span>·</span>
          <poll-common-closing-at :poll="poll"></poll-common-closing-at>
        </div>
      </div>
    </a>
    """
