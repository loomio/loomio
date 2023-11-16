import EventBus from '@/shared/services/event_bus';

export default {
  methods: {
    openChangeVolumeModal(model) {
      return EventBus.$emit('openModal', {
                      component: 'ChangeVolumeForm',
                      props: { model }
                    });
    }
  }
};
