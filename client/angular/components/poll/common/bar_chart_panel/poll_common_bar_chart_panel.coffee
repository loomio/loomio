AppConfig = require 'shared/services/app_config.coffee'
Records   = require 'shared/services/records.coffee'

angular.module('loomioApp').directive 'pollCommonBarChartPanel', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/bar_chart_panel/poll_common_bar_chart_panel.html'
