import AppConfig from '@/shared/services/app_config';
import EventBus from '@/shared/services/event_bus';

const createFlashLevel = (level, duration) => (function(translateKey, translateValues, actionKey, actionFn) {
  if (translateKey) { return EventBus.$emit("flashMessage", {
    level,
    duration:  duration || 4000,
    message:   translateKey,
    options:   translateValues,
    action:    actionKey,
    actionFn
  }
  ); }
});

export default class Flash {
  static success = createFlashLevel('success');
  static info =    createFlashLevel('info');
  static warning = createFlashLevel('warning');
  static error =   createFlashLevel('error');
  static wait =    createFlashLevel('wait', 30000);

  static custom(text, level, duration) {
    if (level == null) { level = 'error'; }
    if (duration == null) { duration = 4000; }
    return EventBus.$emit("flashMessage", {
      text,
      level,
      duration
    });
  }

  static serverError(error, inlineFields = []) {
    if (error.error) {
      Flash.custom(error.error);
    } else if (error.errors) {
      const inlineParts = [];
      const fullParts = [];
      Object.entries(error.errors).forEach(([field, messages]) => {
        if (inlineFields.includes(field)) {
          inlineParts.push(field);
        } else {
          fullParts.push(`${field}: ${[].concat(messages).join(', ')}`);
        }
      });
      const parts = [];
      if (inlineParts.length) { parts.push(`Please check: ${inlineParts.join(', ')}`); }
      fullParts.forEach(p => parts.push(p));
      Flash.custom(parts.join('. '));
    } else {
      Flash.error('common.check_for_errors_and_try_again');
    }
  }
};

window.Loomio.flash = Flash;
