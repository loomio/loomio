/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let MemberhipRecordsInterface;
import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import MemberhipModel       from '@/shared/models/membership_model';
import {includes} from 'lodash';

export default MemberhipRecordsInterface = (function() {
  MemberhipRecordsInterface = class MemberhipRecordsInterface extends BaseRecordsInterface {
    constructor(...args) {
      super(...args);
      this.saveExperience = this.saveExperience.bind(this);
    }

    static initClass() {
      this.prototype.model = MemberhipModel;
    }

    forUser(user) {
      return this.collection.find({userId: user.id});
    }

    forModel(model) {
      return this.collection.find({groupId: {$in: model.groupIds()}});
    }

    forGroup(group) {
      return this.collection.find({groupId: group.id});
    }

    joinGroup(group) {
      return this.remote.post('join_group', {group_id: group.id});
    }

    fetchMyMemberships() {
      return this.fetch({
        path: 'my_memberships'});
    }

    // There's a pattern emerging for searching by fragment...
    fetchByNameFragment(fragment, groupKey, limit = 5) {
      return this.fetch({
        path: 'autocomplete',
        params: { q: fragment, group_key: groupKey, per: limit }});
    }

    // fetchByGroup: (groupKey, options = {}) ->
    //   @fetch
    //     params:
    //       group_key: groupKey
    //       per: options['per'] or 30

    fetchByUser(user, options = {}) {
      return this.fetch({
        path: 'for_user',
        params: {
          user_id: user.id,
          per: options['per'] || 30
        }
      });
    }

    makeAdmin(membership) {
      return this.remote.postMember(membership.id, "make_admin");
    }

    removeAdmin(membership) {
      return this.remote.postMember(membership.id, "remove_admin");
    }

    saveExperience(experience, membership) {
      return this.remote.postMember(membership.id, "save_experience", {experience});
    }
  };
  MemberhipRecordsInterface.initClass();
  return MemberhipRecordsInterface;
})();
