angular.module('loomioApp').directive 'pollMeetingStanceChoice', ->
  scope: {stanceChoice: '='}
  template: require('./poll_meeting_stance_choice.haml')
