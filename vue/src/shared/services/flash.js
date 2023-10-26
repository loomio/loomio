/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let Flash;
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

export default Flash = (function() {
  Flash = class Flash {
    static initClass() {
      this.success = createFlashLevel('success');
      this.info =    createFlashLevel('info');
      this.warning = createFlashLevel('warning');
      this.error =   createFlashLevel('error');
      this.wait =    createFlashLevel('wait', 30000);
    }
    static custom(text, level, duration) {
      if (level == null) { level = 'error'; }
      if (duration == null) { duration = 4000; }
      return EventBus.$emit("flashMessage", {
        text,
        level,
        duration
      }
      );
    }
  };
  Flash.initClass();
  return Flash;
})();

window.Loomio.flash = Flash;
