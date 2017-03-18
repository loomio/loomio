angular.module('loomioApp').directive 'pollMeetingTime', ->
  scope: {name: '='}
  template: "<span>{{formatDate(name)}}</span>"
  controller: ($scope) ->

    $scope.formatDate = (name) ->
      m = moment(name)
      m.format(formatFor(m))

    formatFor = (m) ->
      if m._f == 'YYYY-MM-DD'
        if m.year() == moment().year()
          "D MMMM"
        else
          "D MMMM YYYY"
      else
        if m.year() == moment().year()
          "D MMMM - h:mma"
        else
          "D MMMM YYYY - h:mma"
