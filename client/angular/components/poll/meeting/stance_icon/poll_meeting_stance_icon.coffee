angular.module('loomioApp').directive 'pollMeetingStanceIcon', ->
  replace:true
  scope: {score: '=', threadItem: '=?'}
  template: require('./poll_meeting_stance_icon.haml')
