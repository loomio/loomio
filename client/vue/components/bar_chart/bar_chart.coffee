svg = require 'svg.js'
AppConfig = require 'shared/services/app_config'

module.exports = Vue.component 'BarChart',
  props:
    stanceCounts: Array
    size: String # IK: seems bad
  data: ->
    draw: null
    shapes: []
  computed:
    scoreData: ->
      _.take(_.map(this.stanceCounts, (score, index) ->
        { color: AppConfig.pollColors.poll[index], index: index, score: score }), 5)
    scoreMaxValue: ->
      _.max _.map(this.scoreData, (data) -> data.score)
  methods:
    drawPlaceholder: ->
      _.each this.shapes, (shape) -> shape.remove()
      barHeight = this.size / 3
      barWidths =
        0: this.size
        1: 2 * this.size / 3
        2: this.size / 3
      _.each barWidths, (width, index) =>
        this.draw.rect(width, barHeight - 2)
            .fill("#ebebeb")
            .x(0)
            .y(index * barHeight)
    drawChart: ->
      _.each this.shapes, (shape) -> shape.remove()
      barHeight = this.size / this.scoreData.length
      _.map this.scoreData, (scoreData) =>
        barWidth = _.max([(this.size * this.scoreData.score) / this.scoreMaxValue, 2])
        this.draw.rect(barWidth, barHeight-2)
            .fill(this.scoreData.color)
            .x(0)
            .y(this.scoreData.index * barHeight)
  watch:
    stanceCounts: (newStanceCounts, oldStanceCounts) ->
      if this.scoreData.length > 0 and this.scoreMaxValue > 0
        this.drawChart()
      else
        this.drawPlaceholder()
  template: '<div class="bar-chart"></div>'
  mounted: ->
    this.draw = svg(this.$el).size('100%', '100%')
    if this.scoreData.length > 0 and this.scoreMaxValue > 0
      this.drawChart()
    else
      this.drawPlaceholder()
