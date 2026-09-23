import EventBus from '@/shared/services/event_bus';
import Session from '@/shared/services/session';

export default new class AccountCompletionService {
  required(user = Session.user()) {
    return !user.name || user.legalAcceptanceRequired;
  }

  maybeOpen() {
    const user = Session.user();
    if (!Session.isSignedIn() || !this.required(user)) return Promise.resolve(false);

    return new Promise((resolve) => {
      EventBus.$emit('openModal', {
        component: 'AccountCompletion',
        props: { user, completed: () => resolve(true) },
        maxWidth: 560,
        persistent: true
      });
    });
  }

  openPending(user) {
    EventBus.$emit('openModal', {
      component: 'AccountCompletion',
      props: { user, authenticationPending: true },
      maxWidth: 560,
      persistent: true
    });
  }
}
