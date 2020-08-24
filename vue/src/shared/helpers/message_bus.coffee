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
  io(recordsAddress, query: { channel_token: AppConfig.channel_token}).on('update', (data) => Records.import(data) )
