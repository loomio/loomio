import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import UserModel            from '@/shared/models/user_model';
import AnonymousUserModel   from '@/shared/models/anonymous_user_model';
import {merge, pickBy, identity} from 'lodash-es';

export default class UserRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.updateProfile = this.updateProfile.bind(this);
    this.uploadAvatar = this.uploadAvatar.bind(this);
    this.destroy = this.destroy.bind(this);
    this.saveExperience = this.saveExperience.bind(this);
    this.model = UserModel;
    this.apiEndPoint = 'profile';
    this.baseConstructor(recordStore)
  }

  nullModel() { return new AnonymousUserModel(); }

  fetchTimeZones() {
    return this.remote.fetch({path: "time_zones"});
  }

  fetchGroups() {
    return this.fetch({
      path: "groups",
      params: {
        exclude_types: 'user'
      }
    });
  }

  updateProfile(user) {
    user.processing = true;
    user.beforeSave();
    return this.remote.post('update_profile', merge(user.serialize(), {unsubscribe_token: user.unsubscribeToken }))
    .catch(data => {
      if (data.errors) { user.setErrors(data.errors); }
      throw data;
    }).finally(() => user.processing = false);
  }

  uploadAvatar(file) {
    return this.remote.upload('upload_avatar', file);
  }

  destroy() { return this.remote.delete('/'); }

  saveExperience(name, value) {
    if (value == null) { value = true; }
    return this.remote.post('save_experience', {experience: name, value});
  }

  emailStatus(email, token) {
    return this.fetch({
      path: 'email_status',
      params: pickBy({email, token}, identity)
    });
  }

  checkEmailExistence(email) {
    return this.fetch({
      path: 'email_exists',
      params: {
        email
      }
    });
  }

  sendMergeVerificationEmail(targetEmail) {
    return this.fetch({
      path: 'send_merge_verification_email',
      params: {
        target_email: targetEmail
      }
    });
  }
};
