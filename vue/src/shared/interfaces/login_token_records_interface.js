import BaseRecordsInterface from '@/shared/record_store/base_records_interface';

export default class LoginTokenRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = {
      singular: 'login_token',
      plural:   'login_tokens'
    };
    this.baseConstructor(recordStore);
  }
  fetchToken(email) {
    return this.remote.post('', {email});
  }
}
