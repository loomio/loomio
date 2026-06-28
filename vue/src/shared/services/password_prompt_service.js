import EventBus from '@/shared/services/event_bus';
import Session from '@/shared/services/session';

export default new class PasswordPromptService {
  maybeOpen() {
    const user = Session.user();
    if (!Session.isSignedIn()) { return; }
    if (user.hasPassword !== false) { return; }
    if (user.experiences.passwordPromptDismissed) { return; }

    setTimeout(() => {
      EventBus.$emit('openModal', {
        component: 'SetPasswordPrompt',
        props: { user },
        maxWidth: 480
      });
    });
  }
}
