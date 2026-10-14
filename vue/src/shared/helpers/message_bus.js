import Records  from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';

import { createConsumer } from '@rails/actioncable';

let consumer = null;

export var initLiveUpdate = function() {
  if (consumer) { return; }

  try {
    consumer = createConsumer();

    consumer.subscriptions.create("RecordsChannel", {
      received(data) {
        if (data.records) {
          Records.importJSON(data.records);
        }
        if (data.membership_access) {
          const {group_ids: groupIds, revoked} = data.membership_access;
          if (revoked) {
            Records.memberships.revokeGroupAccess(groupIds);
          } else {
            Records.memberships.restoreGroupAccess(groupIds).catch(error => {
              console.warn('Could not refresh restored group access:', error);
            });
          }
        }
      }
    });

    consumer.subscriptions.create("NoticeChannel", {
      received(data) {
        EventBus.$emit('systemNotice', data);
      }
    });
  } catch (e) {
    console.warn('Failed to initialize live update:', e.message);
    consumer = null;
  }
};

export var closeLiveUpdate = function() {
  if (consumer) {
    consumer.disconnect();
    consumer = null;
  }
};
