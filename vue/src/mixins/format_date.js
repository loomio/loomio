import {approximate, exact, timeline} from '@/shared/helpers/format_time';
import EventBus from '@/shared/services/event_bus';
import AppConfig from '@/shared/services/app_config';
import Session from '@/shared/services/session';
import {each} from 'lodash-es';

var waitFor = function(selector, fn) {
  if (document.querySelector(selector)) {
    fn();
  } else {
    setTimeout(() => waitFor(selector, fn) , 200);
  }
};

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
      this.elementScrollTo(window, selector, callback);
    },

    waitForThenScrollTo(selector) {
      waitFor(selector, () => {
        document.querySelector(selector).scrollIntoView({
          behavior: 'instant'
        });
      });
    },

    elementScrollTo(el, selector, callback) {
      waitFor(selector, () => {
        const offset = 128;
        el.scrollTo({
          behavior: 'smooth',
          top:
            document.querySelector(selector).getBoundingClientRect().top -
            document.body.getBoundingClientRect().top -
            offset,
        })

        if (callback) { callback(); }
      });
    },
    approximateDate(date) { return approximate(date); },
    exactDate(date) { return exact(date); },
    timelineDate(date) { return timeline(date); }
  }
};
