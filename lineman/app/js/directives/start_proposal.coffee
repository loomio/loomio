angular.module('loomioApp').directive 'startProposal', ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/templates/start_proposal.html'
  replace: true
  controller: 'StartProposalController'
  link: (scope, element, attrs) ->
    coverRow = element.find('.card.cover')
    formRow = element.find('.card.form')

    scope.$watch 'isExpanded', (isExpanded) ->
      if isExpanded
        coverRow.addClass('ng-hide')
        formRow.removeClass('ng-hide')
      else
        coverRow.removeClass('ng-hide')
        formRow.addClass('ng-hide')
