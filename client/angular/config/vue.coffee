window.Vue     = require('vue')
window.VueI18n = require('vue-i18n')
window.Vuex    = require('vuex')

require('vue/directives/marked')

Records       = require 'shared/services/records'

Vue.use(VueI18n)
Vue.use(Vuex)


store = require('vue/store/main.coffee')

i18n = new VueI18n
  locale: 'en',
  fallbackLocale: 'en',
  messages:
    en:
      test: "hello bonjour"

fetch('/api/v1/translations?lang=en&vue=true').then (res) ->
  res.json().then (data) ->
    i18n.setLocaleMessage('en', data)

components =
  TimeAgo: require 'vue/components/time_ago/time_ago.coffee'
  ThreadPreview: require 'vue/components/thread_preview/thread_preview.coffee'
  UserAvatar: require 'vue/components/user_avatar/user_avatar.coffee'
  UserAvatarBody: require 'vue/components/user_avatar_body/user_avatar_body.coffee'
  PollCommonChartPreview: require 'vue/components/poll_common_chart_preview/poll_common_chart_preview.coffee'
  PollCommonBarChart: require 'vue/components/poll_common_bar_chart/poll_common_bar_chart.coffee'
  BarChart: require 'vue/components/bar_chart/bar_chart.coffee'
  ProgressChart: require 'vue/components/progress_chart/progress_chart.coffee'
  PollProposalChartPreview: require 'vue/components/poll_proposal_chart_preview/poll_proposal_chart_preview.coffee'
  PollProposalChart: require 'vue/components/poll_proposal_chart/poll_proposal_chart.coffee'
  MatrixChart: require 'vue/components/matrix_chart/matrix_chart.coffee'
  ThreadPreviewCollection: require 'vue/components/thread_preview_collection/thread_preview_collection.coffee'
  GroupPageDiscussionsCard: require 'vue/components/group_page_discussions_card/group_page_discussions_card.coffee'
  GroupPageDescriptionCard: require 'vue/components/group_page_description_card/group_page_description_card.coffee'
  DocumentList: require 'vue/components/document_list/document_list.coffee'
  Loading: require 'vue/components/loading/loading.coffee'
  ActionDock: require 'vue/components/action_dock/action_dock.coffee'
  ThreadCard: require 'vue/components/thread_card/thread_card.coffee'
  ContextPanel: require 'vue/components/context_panel/context_panel.coffee'
  Translation: require 'vue/components/translation/translation.coffee'
  ActivityCard: require 'vue/components/activity_card/activity_card.coffee'
  ThreadItem: require 'vue/components/thread_page_thread_item/thread_item.coffee'
  DecisionToolsCard: require 'vue/components/thread_page_decision_tools_card/decision_tools_card.coffee'
  PollCommonStartForm: require 'vue/components/poll_common_start_form/poll_common_start_form.coffee'
  NewComment: require 'vue/components/thread_page_thread_item/new_comment.coffee'
  OutcomeCreated: require 'vue/components/thread_page_thread_item/outcome_created.coffee'
  PollCreated: require 'vue/components/thread_page_thread_item/poll_created.coffee'
  EventChildren: require 'vue/components/thread_page_event_children/event_children.coffee'
  AddCommentPanel: require 'vue/components/thread_page_add_comment_panel/add_comment_panel.coffee'

_.each components, (obj, name) ->
  angular.module('loomioApp').value(name, Vue.component(name, obj))

angular.module('loomioApp').config ['$ngVueProvider', ($ngVueProvider) ->
  $ngVueProvider.setRootVueInstanceProps({
    i18n: i18n
    store: store
  })
]
