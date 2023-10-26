import EventBus from '@/shared/services/event_bus'

export default (opts) ->
  EventBus.$emit('openModal', opts)
