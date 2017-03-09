angular.module('loomioApp').directive 'pollMeetingTime', ->
  scope: {name: '='}
  template: "<span>{{formatDate(name)}}</span>"
  controller: ($scope) ->

    $scope.formatDate = (name) ->
      m = moment(name)
      m.format(formatFor(m))

    formatFor = (m) ->
      switch m._f
        when "YYYY-MM-DDTHH:mm:ss.SSSSZ"
          if m.year() == moment().year()
            "D MMMM - h:mma"
          else
            "D MMMM YYYY - h:mma"
        when "YYYY-MM-DD"
          if m.year() == moment().year()
            "D MMMM"
          else
            "D MMMM YYYY"
