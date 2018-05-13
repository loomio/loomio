{ submitOnEnter } = require 'shared/helpers/keyboard'

angular.module('loomioApp').directive 'commentFormActions', ->
  scope: {comment: '=', submit: '='}
  replace: true
  templateUrl: 'generated/components/thread_page/comment_form_actions/comment_form_actions.html'
