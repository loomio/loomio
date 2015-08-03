angular.module('loomioApp').directive 'proposalClosingTime', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/components/proposal_closing_time/proposal_closing_time.html'
  replace: true
