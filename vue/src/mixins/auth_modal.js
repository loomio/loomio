/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
import EventBus from '@/shared/services/event_bus';

export default {
  methods: {
    openAuthModal(preventClose) {
      if (preventClose == null) { preventClose = false; }
      return EventBus.$emit('openModal', {component: 'AuthModal', props: {preventClose}} );
    }
  }
};
