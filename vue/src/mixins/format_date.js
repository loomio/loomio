import {approximate, exact, timeline} from '@/shared/helpers/format_time';
import EventBus from '@/shared/services/event_bus';
import AppConfig from '@/shared/services/app_config';
import Session from '@/shared/services/session';
import ScrollService from '@/shared/services/scroll_service';

export default {
  computed: {
    $pollTypes() { return AppConfig.pollTypes; },
    currentUser() { return Session.user(); },
    currentUserId() { return AppConfig.currentUserId; }
  },

  methods: {
    titleVisible(visible) {
      return EventBus.$emit('content-title-visible', visible);
    },

    scrollTo(selector, callback) {
      ScrollService.scrollTo(selector, callback);
    },

    approximateDate(date) { return approximate(date); },
    exactDate(date) { return exact(date); },
    timelineDate(date) { return timeline(date); }
  }
};
