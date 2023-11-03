import BaseModel from '@/record_store/base_model';

export default class ContactRequestModel extends BaseModel {
  static singular = 'contactRequest';
  static plural = 'contactRequests';

  defaultValues() {
    return {message: ''};
  }
}
