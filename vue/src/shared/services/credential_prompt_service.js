import EventBus from '@/shared/services/event_bus';
import Session from '@/shared/services/session';

export default new class CredentialPromptService {
  maybeOpen() {
    const user = Session.user();
    if (!Session.isSignedIn()) return;
    if (user.hasPassword !== false) return;
    if (user.experiences.credentialPromptDismissed || user.experiences.passwordPromptDismissed) return;

    setTimeout(() => {
      EventBus.$emit('openModal', {
        component: 'CredentialPrompt',
        props: { user },
        maxWidth: 560
      });
    });
  }
}
