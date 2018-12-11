{ fieldFromTemplate, myLastStanceFor } = require 'shared/helpers/poll'
LmoUrlService = require 'shared/services/lmo_url_service'

module.exports = Vue.component 'BarChart',
  props:
    poll: Object
  methods:
    urlFor: (model) -> LmoUrlService.route(model: model)
  computed:
    countFor: (option) -> this.poll.stanceData[option.name] or 0
    barTextFor: (option) -> "#{$this.countFor(option)} - #{option.name}".replace(/\s/g, '\u00a0')
    percentageFor: (option) ->
      max = _.max(_.values(this.poll.stanceData))
      return unless max > 0
      "#{100 * this.countFor(option) / max}%"
    backgroundImageFor: (option) ->
      "url(/img/poll_backgrounds/#{option.color.replace('#','')}.png)"
    styleData: (option) ->
      'background-image': backgroundImageFor(option)
      'background-size': "#{percentageFor(option)} 100%"
    orderedPollOptions: ->
      _.orderBy(this.poll, 'priority')
  template: """
<div class="poll-common-bar-chart">
  <div v-for="option in orderedPollOptions" :key="option.id" :style="styleData(option)" class="poll-common-bar-chart__bar">{{barTextFor(option)}}</div>
</div>
"""
