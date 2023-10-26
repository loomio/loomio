import AppConfig      from '@/shared/services/app_config'
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import Flash   from '@/shared/services/flash'
import AuthService    from '@/shared/services/auth_service'
import AbilityService from '@/shared/services/ability_service'
import EventBus       from '@/shared/services/event_bus'

import { each } from 'lodash'

import io from 'socket.io-client'

roomScores = {}
recordsSocket = null

export initLiveUpdate = ->
  recordsAddress = [AppConfig.theme.channels_uri, 'records'].join('/')
  recordsSocket = io(recordsAddress, query: { channel_token: AppConfig.channel_token})

  recordsSocket.on 'update', (data) =>
    if data.notice
      EventBus.$emit('systemNotice', data)
    else
      # console.log 'records update', data.room, data.records
      roomScores[data.room] = data.score
      Records.importJSON(data.records)

  recordsSocket.on 'reconnect', (data) =>
    console.log("socket.io reconnect", {roomScores: roomScores})
    recordsSocket.emit "catchup", roomScores, (recordSets) =>
      console.log("catchup reply", recordSets)
      recordSets.forEach((set) => Records.importJSON(set))

  recordsSocket.on 'disconnect', (data) =>
    # Flash.warning("server disconnected")
    console.log("socket.io disconnect")

  recordsSocket.on 'connect', (data) =>
    # Flash.warning("server connected")
    console.log("socket.io connect")

export closeLiveUpdate = ->
  recordsSocket.close()
