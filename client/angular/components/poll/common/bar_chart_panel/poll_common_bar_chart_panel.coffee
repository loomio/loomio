AppConfig = require 'shared/services/app_config'
Records   = require 'shared/services/records'

angular.module('loomioApp').directive 'pollCommonBarChartPanel', ->
  scope: {poll: '='}
  template: require('./poll_common_bar_chart_panel.haml')
