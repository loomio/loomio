import EventBus from '@/shared/services/event_bus';

export default {
  methods: {
    closeModal() { return EventBus.$emit('closeModal'); }
  }
}
