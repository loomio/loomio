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

roomScores = {}
recordsSocket = null

export initLiveUpdate = ->
  recordsAddress = [AppConfig.theme.channels_uri, 'records'].join('/')
  recordsSocket = io(recordsAddress, query: { channel_token: AppConfig.channel_token})

  recordsSocket.on 'update', (data) =>
    console.log("socket.io update", data)
    roomScores[data.room] = data.score
    Records.import(data.records)

  recordsSocket.on 'reconnect', (data) =>
    console.log("socket.io reconnect")
    recordsSocket.emit "hey", roomScores, (answer) =>
      console.log("hey answer", answer)

  recordsSocket.on 'disconnect', (data) =>
    console.log("socket.io disconnect")

  recordsSocket.on 'connect', (data) =>
    console.log("socket.io connect")
