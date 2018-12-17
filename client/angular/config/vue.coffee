window.VueI18n = require('vue-i18n')
window.Vue     = require('vue')
Vue.use(VueI18n)

window.i18n = new VueI18n(
  locale: 'en',
  fallbackLocale: 'en',
  messages:
    en:
      test: "hello bonjour"
)

fetch('/api/v1/translations?lang=en').then (res)->
  res.json().then (data) ->
    i18n.setLocaleMessage('en', data)

# vue = new Vue(
#   el: '#app',
#   components:
#     TimeAgo:       require('vue/components/time_ago/time_ago.coffee')
#     ThreadPreview: require('vue/components/thread_preview/thread_preview.coffee')
#   i18n: i18n
# )

angular.module('loomioApp').value('TimeAgo', require 'vue/components/time_ago/time_ago.coffee')
angular.module('loomioApp').value('ThreadPreview', require 'vue/components/thread_preview/thread_preview.coffee')
angular.module('loomioApp').value('UserAvatar', require 'vue/components/user_avatar/user_avatar.coffee')
angular.module('loomioApp').value('UserAvatarBody', require 'vue/components/user_avatar_body/user_avatar_body.coffee')
angular.module('loomioApp').value('PollCommonChartPreview', require 'vue/components/poll_common_chart_preview/poll_common_chart_preview.coffee')
angular.module('loomioApp').value('PollCommonBarChart', require 'vue/components/poll_common_bar_chart/poll_common_bar_chart.coffee')
angular.module('loomioApp').value('BarChart', require 'vue/components/bar_chart/bar_chart.coffee')
angular.module('loomioApp').value('ProgressChart', require 'vue/components/progress_chart/progress_chart.coffee')
angular.module('loomioApp').value('PollProposalChartPreview', require 'vue/components/poll_proposal_chart_preview/poll_proposal_chart_preview.coffee')
angular.module('loomioApp').value('PollProposalChart', require 'vue/components/poll_proposal_chart/poll_proposal_chart.coffee')
angular.module('loomioApp').value('MatrixChart', require 'vue/components/matrix_chart/matrix_chart.coffee')
angular.module('loomioApp').value('ThreadPreviewCollection', require 'vue/components/thread_preview_collection/thread_preview_collection.coffee')
angular.module('loomioApp').value('GroupPageDiscussionsCard', require 'vue/components/group_page_discussions_card/group_page_discussions_card.coffee')
angular.module('loomioApp').value('Loading', require 'vue/components/loading/loading.coffee')
angular.module('loomioApp').config ['$ngVueProvider', ($ngVueProvider) ->
  $ngVueProvider.setRootVueInstanceProps({
    i18n: i18n
  })
]
