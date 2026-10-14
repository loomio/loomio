import BaseRecordsInterface from '@/shared/record_store/base_records_interface';
import MemberhipModel       from '@/shared/models/membership_model';
import AppConfig from '@/shared/services/app_config';
import {invokeMap} from 'lodash-es';

export default class MemberhipRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = MemberhipModel;
    this.baseConstructor(recordStore);
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
    return this.remote.post('join_group', {group_id: group.id})
      .then(result => this.restoreGroupAccess([group.id]).then(() => result));
  }

  // The same invalidation applies to a successful local leave and a realtime
  // revocation received in another tab or after an administrator removes us.
  revokeGroupAccess(groupIds) {
    const records = this.recordStore;
    const userId = AppConfig.currentUserId;
    invokeMap(this.find({userId, groupId: {$in: groupIds}}), 'remove');
    records.topics.find({groupId: {$in: groupIds}}).forEach(topic => {
      topic.update({readerGuest: false, readerAdmin: false});
    });
    const groupPolls = records.polls.find({groupId: {$in: groupIds}});
    groupPolls.forEach(poll => poll.update({voterHasAccess: false}));
    const polls = groupPolls.filter(poll => poll.isVotable());
    polls.forEach(poll => poll.update({myStanceId: null, anonymousVoterEligible: false}));
    invokeMap(records.stances.find({participantId: userId, pollId: {$in: polls.map(poll => poll.id)}}), 'remove');
    records.updateViews(['memberships', 'topics', 'polls', 'stances']);
  }

  async restoreGroupAccess(groupIds) {
    const records = this.recordStore;
    // Page recent polls so returning members recover their own voting state,
    // including in groups with more polls than fit in the first response.
    for (const groupId of groupIds) {
      const group = await records.groups.findOrFetch(groupId);
      // Restore access on cached closed polls too, so a later reopen works
      // even when the poll is older than the recent-polls fetch below.
      const voterHasAccess = this.find({userId: AppConfig.currentUserId, groupId}).length > 0;
      records.polls.find({groupId}).forEach(poll => poll.update({voterHasAccess}));
      records.updateViews(['polls']);
      let offset = 0;
      let total;
      do {
        const data = await records.polls.fetch({params: {
          group_key: group.key, subgroups: 'none', status: 'recent', limit: 100, offset
        }});
        total = data.meta.total;
        offset += 100;
      } while (offset < total);
    }
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
