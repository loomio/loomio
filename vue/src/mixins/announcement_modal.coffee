import EventBus from '@/shared/services/event_bus'

export default
  methods:
    openAnnouncementModal: (announcement) ->
      EventBus.$emit('openModal',
                      component: 'AnnouncementForm',
                      props: { announcement: announcement })
