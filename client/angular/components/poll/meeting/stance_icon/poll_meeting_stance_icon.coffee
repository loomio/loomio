angular.module('loomioApp').directive 'pollMeetingStanceIcon', ->
  replace:true
  scope: {score: '=', threadItem: '=?'}
  templateUrl: 'generated/components/poll/meeting/stance_icon/poll_meeting_stance_icon.html'
