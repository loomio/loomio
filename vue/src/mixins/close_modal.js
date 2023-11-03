import EventBus from '@/services/event_bus';

export default {
  methods: {
    closeModal() { return EventBus.$emit('closeModal'); }
  }
}
