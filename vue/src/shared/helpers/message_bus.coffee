import AppConfig      from '@/shared/services/app_config'
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import Flash   from '@/shared/services/flash'
import AuthService    from '@/shared/services/auth_service'
import AbilityService from '@/shared/services/ability_service'
import EventBus       from '@/shared/services/event_bus'

import { hardReload } from '@/shared/helpers/window'
import { each } from 'lodash'

import io from 'socket.io-client'

export initLiveUpdate = ->

  recordsAddress = [AppConfig.theme.channels_uri, 'records'].join('/')
  socket = io(recordsAddress, query: { channel_token: AppConfig.channel_token})
    .on('update', (data) =>
      console.log "socket records update", data
    )
  # MessageBus.start()
  # MessageBus.subscribe '/notices', (data) ->
  #   console.log "subscribed to notices", data
  # if data.version?
  #   Flash.update 'global.messages.app_update', {version: data.version}, 'global.messages.reload', hardReload
  # after sign in
  # MessageBus.callbackInterval = 500
  # if Session.isSignedIn()
  #   MessageBus.subscribe "/records", (data) -> Records.import(data)
  #
  # EventBus.$on 'signedIn', (user) =>
  #   MessageBus.subscribe "/records", (data) -> Records.import(data)
