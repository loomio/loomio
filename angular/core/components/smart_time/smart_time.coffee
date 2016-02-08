angular.module('loomioApp').directive 'smartTime', ->
  scope: {time: '='}
  restrict: 'E'
  templateUrl: 'generated/components/smart_time/smart_time.html'
  replace: true
  controller: ($scope) ->
    time = moment($scope.time)
    now = moment()

    sameDay = (time) ->
      time.year() == now.year() and
      time.month() == now.month() and
      time.date() == now.date()

    sameWeek = (time) ->
      time.year() == now.year() and
      time.month() == now.month() and
      time.week() == now.week()

    sameYear = (time) ->
      time.year() == now.year()

    format = switch
      when sameDay(time) then "h:mm a"
      when sameWeek(time) then "ddd"
      when sameYear(time) then "D MMM"
      else "MMM YYYY"

    $scope.value = time.format(format)
