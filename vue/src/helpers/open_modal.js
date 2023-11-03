import EventBus from '@/services/event_bus';

export default opts => EventBus.$emit('openModal', opts);
