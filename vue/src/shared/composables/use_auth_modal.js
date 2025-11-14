import EventBus from '@/shared/services/event_bus';

export function useAuthModal() {
  const openAuthModal = (preventClose = false) => {
    return EventBus.$emit('openModal', { 
      component: 'AuthModal', 
      props: { preventClose } 
    });
  };

  return {
    openAuthModal
  };
}