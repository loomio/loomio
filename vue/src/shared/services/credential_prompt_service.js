import EventBus from '@/shared/services/event_bus';
import Session from '@/shared/services/session';

export default new class CredentialPromptService {
  // Code sign-ins always offer credential choices. Password sign-ins offer a
  // passkey until the user adds one or dismisses the offer.
  maybeOpen({ signedInViaCode = false, signedInViaPassword = false } = {}) {
    const user = Session.user();
    if (!Session.isSignedIn()) return;

    const passkeySupported = globalThis.PublicKeyCredential?.parseCreationOptionsFromJSON &&
      globalThis.PublicKeyCredential?.parseRequestOptionsFromJSON &&
      globalThis.PublicKeyCredential?.prototype?.toJSON;
    let promptType;

    if (signedInViaCode) {
      promptType = 'code';
    } else if (signedInViaPassword && passkeySupported && !user.hasPasskey) {
      if (user.experiences.passkeyPromptDismissed || user.experiences.credentialPromptDismissed) return;
      promptType = 'passkey';
    } else {
      return;
    }

    setTimeout(() => {
      EventBus.$emit('openModal', {
        component: 'CredentialPrompt',
        props: { user, promptType, passkeySupported: Boolean(passkeySupported) },
        maxWidth: 560
      });
    });
  }
}
