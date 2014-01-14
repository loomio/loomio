angular.module('loomioApp').filter 'timeFromNowInWords', ->
	(date) ->
		moment(date).fromNow(true)