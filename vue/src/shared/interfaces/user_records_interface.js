import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import UserModel            from '@/shared/models/user_model';
import AnonymousUserModel   from '@/shared/models/anonymous_user_model';
import {merge, pickBy, identity} from 'lodash-es';

let groupsFetchedOnce = false;

export default class UserRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.fetchMentionable = this.fetchMentionable.bind(this);
    this.updateProfile = this.updateProfile.bind(this);
    this.uploadAvatar = this.uploadAvatar.bind(this);
    this.changePassword = this.changePassword.bind(this);
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

  findOrFetchGroups() {
    if (groupsFetchedOnce) {
      this.fetchGroups();
      return Promise.resolve(true);
    } else {
      return this.fetchGroups().then(() => groupsFetchedOnce = true);
    }
  }

  fetchGroups() {
    return this.fetch({
      path: "groups",
      params: {
        exclude_types: 'user'
      }
    });
  }

  fetchMentionable(q, model) {
    if ((model.id == null) && model.discussionId) { model = model.discussion(); }
    if ((model.id == null) && !model.discussionId) { model = model.group(); }
    return this.fetch({
      path: 'mentionable_users',
      params: {
        q,
        [`${model.constructor.singular}_id`]: model.id
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

  changePassword(user) {
    user.processing = true;
    return this.remote.post('change_password', user.serialize()).finally(() => user.processing = false);
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
