/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let SessionModel;
import BaseModel from '@/shared/record_store/base_model';

export default SessionModel = (function() {
  SessionModel = class SessionModel extends BaseModel {
    static initClass() {
      this.singular = 'session';
      this.plural = 'sessions';
      this.serializableAttributes = ['type', 'code', 'email', 'password', 'rememberMe'];
      this.serializationRoot = 'user';
    }
  };
  SessionModel.initClass();
  return SessionModel;
})();
