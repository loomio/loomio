require 'url-search-params-polyfill';
import RestfulClient from '@/shared/record_store/restful_client'

export bootDat = (callback) ->
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
