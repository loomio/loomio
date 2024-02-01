import {approximate, exact, timeline} from '@/shared/helpers/format_time';
import EventBus from '@/shared/services/event_bus';
import AppConfig from '@/shared/services/app_config';
import Session from '@/shared/services/session';
import {each} from 'lodash-es';

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
      var waitFor = function(selector, fn) {
        if (document.querySelector(selector)) {
          fn();
        } else {
          // console.log 'waiting for ', selector
          setTimeout(() => waitFor(selector, fn)
          , 500);
        }
      };

      waitFor(selector, () => {
        this.$vuetify.goTo(selector, {duration: 0, offset: 32});
        each([1,2,3], n => {
          const headingSelector = selector+` h${n}[tabindex=\"-1\"]`;
          if (document.querySelector(headingSelector)) {
            document.querySelector(headingSelector).focus();
            return false;
          } else {
            return true;
          }
        });
        if (callback) { callback(); }
      });
    },
    approximateDate(date) { return approximate(date); },
    exactDate(date) { return exact(date); },
    timelineDate(date) { return timeline(date); }
  }
};
