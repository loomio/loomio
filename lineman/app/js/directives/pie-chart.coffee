angular.module('loomioApp').directive 'pieChart', ->
	scope: { 'ngModel': '='}
	restrict: 'EA'
	require: 'ngModel'
	controller: 'ProposalController'
	link: (scope, element, attrs, ctrl) ->
		console.log scope.ngModel

		scope.$watch 'ngModel', (newData, oldData) ->
			console.log 'newData', newData
