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
};

window.Loomio.flash = Flash;
