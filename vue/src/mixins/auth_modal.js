import EventBus from '@/shared/services/event_bus';

export default {
  methods: {
    openAuthModal(preventClose) {
      if (preventClose == null) { preventClose = false; }
      return EventBus.$emit('openModal', {component: 'AuthModal', props: {preventClose}} );
    }
  }
};
