/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let LoginTokenRecordsInterface;
import BaseRecordsInterface from '@/shared/record_store/base_records_interface';

export default LoginTokenRecordsInterface = (function() {
  LoginTokenRecordsInterface = class LoginTokenRecordsInterface extends BaseRecordsInterface {
    static initClass() {
      this.prototype.model = {
        singular: 'login_token',
        plural:   'login_tokens'
      };
    }

    fetchToken(email) {
      return this.remote.post('', {email});
    }
  };
  LoginTokenRecordsInterface.initClass();
  return LoginTokenRecordsInterface;
})();
