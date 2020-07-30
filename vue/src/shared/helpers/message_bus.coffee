import AppConfig      from '@/shared/services/app_config'
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import Flash   from '@/shared/services/flash'
import AuthService    from '@/shared/services/auth_service'
import AbilityService from '@/shared/services/ability_service'
import EventBus       from '@/shared/services/event_bus'

import { hardReload } from '@/shared/helpers/window'
import { each } from 'lodash-es'

export subscribeTo = (model) ->
  switch model.constructor.singular
    when 'group' then subscribeToGroup(model)
    when 'poll'  then subscribeToPoll(model)

export initLiveUpdate = ->
  console.log "initing"
  console.log MessageBus.start()
  # MessageBus.subscribe '/notices', (data) ->
  #   console.log "subscribed to notices", data
  # if data.version?
  #   Flash.update 'global.messages.app_update', {version: data.version}, 'global.messages.reload', hardReload
  # after sign in
  MessageBus.callbackInterval = 500
  if Session.isSignedIn()
    MessageBus.subscribe "/records", (data) -> Records.import(data)

  EventBus.$on 'signedIn', (user) =>
    MessageBus.subscribe "/records", (data) -> Records.import(data)

#
# subscribeToDiscussion = (poll) ->
#   ensureConnection().subscriptions.create { channel: "PollChannel", poll_id: poll.id },
#     received: (data) -> Records.import(data)

# subscribeToApplication = ->
