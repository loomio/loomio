angular.module('loomioApp').directive 'pieChart', (d3Helpers) ->
	scope: { 'ngModel': '='}
	restrict: 'EA'
	require: 'ngModel'
	controller: 'ProposalController'
	link: (scope, element, attrs, ctrl) ->

		sizeChart = (element) ->
			cardWidth = element[0].clientWidth

		##set attribute defaults and d3 method aliases
		size = attrs.width ? sizeChart element
		r = attrs.radius ? size/2
		arc = d3.svg.arc().innerRadius(0).outerRadius(r)
		pie = d3.layout.pie().value (d) -> d.count
		arcTween = (a) ->
			console.log 'a', a, @
			i = d3.interpolate @._current, a
			@._current = i 0
			(t) ->
				arc(i(t))

		arcSet = (d) ->
			@._current =
				startAngle: d.startAngle
				endAngle: d.startAngle
				data:
					count: 1
					type: d.data.type

		## draw our base svg and add a g element to group the arcs
		arcGroup = d3Helpers.setChartAttrs element, size

		## set piechart initial position at angle 0 if proposal.created_at < 3000ms
		initData = d3Helpers.setPieInitData scope.ngModel, pie
		console.log 'initData', initData

		## create arc objects with .data() instantiated with initData as placeholder
		arcs = arcGroup.selectAll('path').data(initData, (d) -> d.data.type)
		  .enter().append('path')
		  .attr('d', arc)
		  .attr('class', (d) -> d.data.type)
		  .each((d) -> @._current = d)

		## watch for changes to proposal; make new array; make pie layout of array;
		## attach to arcs object; and transition old to new points
		scope.$watch 'ngModel', (updatedProposal, oldProposal) ->
			if updatedProposal
				console.log 'update', updatedProposal
				d = d3Helpers.proposalArray updatedProposal
				console.log 'd', d
				pies = pie(d)
				console.log 'pie', pies

				console.log 'arc', arc(pies[0])

				a = arcGroup.selectAll('path').data(pie(d), (d) -> d.data.type )

				a.exit().remove()

				newArcs = a
				  .enter().append('path')
				  .each(arcSet)
				  .attr('class', (d) -> d.data.type)
				  .transition().duration(350)
				  .attrTween('d', arcTween)

				a.transition().duration(350)
				  .attrTween('d', arcTween)


		## watch for changes in screen size and resize chart
		scope.$watch scope.getScreenWidth, (resized) ->
			if resized?
				size = sizeChart element
				d3Helpers.setChartAttrs element, size
				## reset arc radius
				arc.outerRadius(size/2)
				arcs.attr('d', arc)





