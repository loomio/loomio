RestfulClient = require 'shared/record_store/restful_client'

module.exports =
  bootDat: (callback) ->
    client = new RestfulClient('boot')
    client.get('site').then (siteResponse) ->
      client.get('user').then (userResponse) ->
        if _.all _.pluck([siteResponse, userResponse], 'ok')
          siteResponse.json().then (site) ->
            userResponse.json().then (user) ->
              callback(_.merge(site, userPayload: user))
        else
          console.log 'Could not boot Loomio!'
          callback({})
