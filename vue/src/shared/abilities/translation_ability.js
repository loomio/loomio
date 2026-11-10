import AppConfig from '@/shared/services/app_config';
import Session from '@/shared/services/session';

export default {
  canTranslate(model) {
    return !model.discardedAt &&
           AppConfig.inlineTranslation.isAvailable &&
           !model.translationId &&
           model.contentLocale &&
           model.contentLocale !== Session.user().locale &&
           !model.isBlank() &&
           Session.isSignedIn();
  },

  canUntranslate(model) {
    return !!model.translationId;
  }
};
