angular.module('loomioApp').factory 'ChargifyService', (User) ->
  new class ChargifyService

    encodedParams: (group) ->
      params =
        first_name:   User.current().firstName()
        last_name:    User.current().lastName()
        email:        User.current().email
        organization: group.name
        reference:    "#{group.key}|#{moment().unix()}"

      _.map(_.keys(params), (key) ->
        encodeURIComponent(key) + "=" + encodeURIComponent(params[key])
      ).join('&')
