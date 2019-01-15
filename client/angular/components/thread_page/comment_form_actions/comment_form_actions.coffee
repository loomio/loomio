{ submitOnEnter } = require 'shared/helpers/keyboard'

angular.module('loomioApp').directive 'commentFormActions', ->
  scope: {comment: '=', submit: '='}
  replace: true
  template: require('./comment_form_actions.haml')
