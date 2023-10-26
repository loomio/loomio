/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let SessionRecordsInterface;
import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import SessionModel         from '@/shared/models/session_model';

export default SessionRecordsInterface = (function() {
  SessionRecordsInterface = class SessionRecordsInterface extends BaseRecordsInterface {
    static initClass() {
      this.prototype.model = SessionModel;
    }
  };
  SessionRecordsInterface.initClass();
  return SessionRecordsInterface;
})();
