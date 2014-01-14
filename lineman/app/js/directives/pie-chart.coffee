angular.module('loomioApp').directive 'pieChart', (d3Helpers) ->
	scope: { 'ngModel': '='}
	restrict: 'EA'
	require: 'ngModel'
	controller: 'ProposalController'
	link: (scope, element, attrs, ctrl) ->

		##set attribute defaults and d3 method aliases
		w = attrs.width || 398
		h = attrs.height || 249
		r = attrs.radius || 50
		color = d3.scale.linear()
		  .domain(['yes', 'no', 'abstain', 'block', 'none'])
		  .range(['#90D490', '#D49090', '#F0BB67', '#DD0000', '#EBEBEB'])
		arc = d3.svg.arc().outerRadius r
		pie = d3.layout.pie().value (d) -> d.count
		arcTween = (a) ->
    	i = d3.interpolate(this._current, a)
    	this._current = i(0)
    	(t) ->
    		arc(i(t))

		## draw our base svg
		svg = d3.select(element[0])
		  .append('svg')
		  .attr('width', w)
		  .attr('height', h)
		  .append('g')
		    .attr('id', 'arcs')
		    .attr('transform', 'translate('+w/3+','+h/2+')')

		##
		initData = 
			startAngle: 0
			endAngle: 0
			value: 0
			data:
				type: 'none'
				count: 0

		## create arc objects with .data() instantiated with initData 
		arcs = svg.selectAll('path').data([initData], (d) -> d.type)
		  .enter().append('path')
		  .attr('d', arc)
		  .attr('class', (d) -> d.data.type)
		  .each((d) -> this._current = d)

		## watch for changes to proposal; make new array; make pie layout of array;
		## attach to arcs object; and transition old to new points
		scope.$watch 'ngModel', (updatedProposal) ->
			if updatedProposal
				d = d3Helpers.proposalArray updatedProposal
				arcs.data(pie(d))
				  .transition()
				  .attrTween('d', arcTween)

				console.log 'data', d, pie(d), updatedProposal

			else
				return



