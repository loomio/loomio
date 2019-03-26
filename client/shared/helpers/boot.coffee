require 'url-search-params-polyfill';
RestfulClient = require 'shared/record_store/restful_client'

module.exports =
  bootDat: (callback) ->
    token  = new URLSearchParams(location.search).get('unsubscribe_token')
    client = new RestfulClient('boot')
    client.get('site').then (siteResponse) ->
      client.get('user', unsubscribe_token: token).then (userResponse) ->
        if _.every _.map([siteResponse, userResponse], 'ok')
          siteResponse.json().then (site) ->
            userResponse.json().then (user) ->
              callback(_.merge(site, userPayload: user))
        else
          console.log 'Could not boot Loomio!'
          callback({})
