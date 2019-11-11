import EventBus from '@/shared/services/event_bus'

export default
  methods:
    closeModal: -> EventBus.$emit('closeModal')
