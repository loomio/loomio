import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import UserModel            from '@/shared/models/user_model';
import AnonymousUserModel   from '@/shared/models/anonymous_user_model';
import AppConfig from '@/shared/services/app_config';

export default class UserRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = UserModel;
    this.apiEndPoint = 'profile';
    this.baseConstructor(recordStore)
  }

  nullModel() { return new AnonymousUserModel(); }

  fetchTimeZones() {
    return this.remote.fetch({path: "time_zones"});
  }

  fetchGroups() {
    if (AppConfig.groupsLoaded) return Promise.resolve();
    return this.refreshGroups();
  }

  refreshGroups() {
    this.groupsPromise ||= this.fetch({
      path: "groups",
      params: {
        exclude_types: 'user'
      }
    }).then(data => {
      AppConfig.groupsLoaded = true;
      return data;
    }).finally(() => { this.groupsPromise = null; });
    return this.groupsPromise;
  }

  updateProfile(user) {
    user.processing = true;
    user.prepareForSave();
    return this.remote.post('update_profile', user.serialize())
    .catch(data => {
      if (data.errors) { user.setErrors(data.errors); }
      throw data;
    }).finally(() => user.processing = false);
  }

  setTimeZone(timeZone) {
    return this.remote.post('set_time_zone', { time_zone: timeZone });
  }

  uploadAvatar(file) {
    return this.remote.upload('upload_avatar', file);
  }

  destroy() { return this.remote.delete('/'); }

  saveExperience(name, value) {
    if (value == null) { value = true; }
    return this.remote.post('save_experience', {experience: name, value});
  }

  sendMergeVerificationEmail(targetEmail) {
    return this.remote.post('send_merge_verification_email', {
      target_email: targetEmail
    });
  }
};
