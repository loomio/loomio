angular.module('loomioApp').factory 'ChargifyService', (CurrentUser) ->
  new class ChargifyService

    encodedParams: (group) ->
      params =
        first_name:   CurrentUser.firstName()
        last_name:    CurrentUser.lastName()
        email:        CurrentUser.email
        organization: group.name
        reference:    "#{group.key}|#{moment().unix()}"

      _.map(_.keys(params), (key) ->
        encodeURIComponent(key) + "=" + encodeURIComponent(params[key])
      ).join('&')
