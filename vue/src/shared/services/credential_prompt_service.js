import EventBus from '@/shared/services/event_bus';
import Session from '@/shared/services/session';

export default new class CredentialPromptService {
  maybeOpen() {
    const user = Session.user();
    if (!Session.isSignedIn()) return;

    const passkeySupported = globalThis.PublicKeyCredential?.parseCreationOptionsFromJSON &&
      globalThis.PublicKeyCredential?.parseRequestOptionsFromJSON &&
      globalThis.PublicKeyCredential?.prototype?.toJSON;
    let promptType;

    if (passkeySupported && !user.hasPasskey) {
      if (user.experiences.passkeyPromptDismissed || user.experiences.credentialPromptDismissed) return;
      promptType = 'passkey';
    } else if (!passkeySupported && user.hasPassword === false) {
      if (user.experiences.passwordPromptDismissed || user.experiences.credentialPromptDismissed) return;
      promptType = 'password';
    } else {
      return;
    }

    setTimeout(() => {
      EventBus.$emit('openModal', {
        component: 'CredentialPrompt',
        props: { user, promptType },
        maxWidth: 560
      });
    });
  }
}
