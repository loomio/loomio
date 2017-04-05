angular.module('loomioApp').directive 'pollMeetingTime', (AppConfig) ->
  scope: {name: '=', zone: '='}
  template: "<span>{{formatDate(name)}}</span>"
  controller: ($scope) ->
    $scope.formatDate = (name) ->
      m = moment(name)
      if m._f == 'YYYY-MM-DD'
        m.format("D MMMM#{sameYear(m)}")
      else
        m.tz($scope.zone || AppConfig.timeZone).format("D MMMM#{sameYear(m)} - h:mma")

    sameYear = (m) ->
      if m.year() == moment().year() then "" else " YYYY"
