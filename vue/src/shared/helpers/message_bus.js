import AppConfig      from '@/shared/services/app_config';
import Session        from '@/shared/services/session';
import Records        from '@/shared/services/records';
import Flash          from '@/shared/services/flash';
import AuthService    from '@/shared/services/auth_service';
import AbilityService from '@/shared/services/ability_service';
import EventBus       from '@/shared/services/event_bus';

import io from 'socket.io-client';

let conn = null;

export var initLiveUpdate = function() {
  conn = io(AppConfig.theme.channels_url, {query: { channel_token: AppConfig.channel_token}});

  conn.on('notice', data => {
    EventBus.$emit('systemNotice', data);
  });

  conn.on('records', data => {
    Records.importJSON(data.records);
  });

  conn.on('reconnect', data => {
    // console.debug("socket.io reconnect");
  });

  conn.on('disconnect', data => {
    // console.debug("socket.io disconnect");
  });

  conn.on('connect', data => {
    // console.debug("socket.io connect");
  });
};

export var closeLiveUpdate = () => conn.close();
