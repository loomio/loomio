import AppConfig      from '@/shared/services/app_config'
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import Flash   from '@/shared/services/flash'
import AuthService    from '@/shared/services/auth_service'
import AbilityService from '@/shared/services/ability_service'

import { hardReload } from '@/shared/helpers/window'
import { each } from 'lodash-es'

export subscribeTo = (model) ->
  switch model.constructor.singular
    when 'group' then subscribeToGroup(model)
    when 'poll'  then subscribeToPoll(model)

export initLiveUpdate = ->
  console.log "initing"
  console.log MessageBus.start()
  MessageBus.subscribe '/notices', (data) ->
    console.log "subscribed to notices", data
    # if data.version?
    #   Flash.update 'global.messages.app_update', {version: data.version}, 'global.messages.reload', hardReload
  MessageBus.callbackInterval = 500
  if Session.isSignedIn()
    MessageBus.subscribe "/user-#{Session.user().key}", (data) ->
      console.log "user data!", data
      Records.import(data)

subscribeToUser = (user) ->
  MessageBus.subscribe "/user-#{group.key}", (data) ->
    console.log "gruup data!", data
    Records.import(data)

subscribeToGroup = (group) ->
  MessageBus.subscribe "/group-#{group.key}", (data) ->
    console.log "gruup data!", data
    Records.import(data)

subscribeToPoll = (poll) ->
  MessageBus.subscribe "/poll-#{poll.key}", (data) ->
    console.log "poll data!", data
    Records.import(data)
#
# subscribeToDiscussion = (poll) ->
#   ensureConnection().subscriptions.create { channel: "PollChannel", poll_id: poll.id },
#     received: (data) -> Records.import(data)

# subscribeToApplication = ->
