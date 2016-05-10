angular.module('loomioApp').factory 'ChargifyService', (Session) ->
  new class ChargifyService

    encodedParams: (group) ->
      params =
        first_name:   Session.user().firstName()
        last_name:    Session.user().lastName()
        email:        Session.user().email
        organization: group.name
        reference:    "#{group.key}|#{moment().unix()}"

      _.map(_.keys(params), (key) ->
        encodeURIComponent(key) + "=" + encodeURIComponent(params[key])
      ).join('&')
