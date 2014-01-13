angular.module('loomioApp').directive 'pieChart', ->
	scope: { 'ngModel': '='}
	restrict: 'EA'
	require: 'ngModel'
	controller: 'ProposalController'
	link: (scope, element, attrs, ctrl) ->
		console.log scope.ngModel

		w = attrs.width || 398
		h = attrs.height || 249
		r = attrs.radius || 50
		color = d3.scale.linear()
		  .domain(['yes', 'no', 'abstain', 'block', 'none'])
		  .range(['#90D490', '#D49090', '#F0BB67', '#DD0000', '#EBEBEB'])
		arc = d3.svg.arc().outerRadius r
		pie = d3.layout.pie().value (d) -> d.count

		svg = d3.select(element[0])
		  .append('svg')
		  .attr('width', w)
		  .attr('height', h)
		  .append('g')
		    .attr('transform', 'translate('+w/3+','+h/2+')')

		scope.$watch 'ngModel', (newData, oldData) ->
			console.log 'newData', newData, d3


