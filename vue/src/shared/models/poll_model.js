import BaseModel        from '@/shared/record_store/base_model';
import AppConfig        from '@/shared/services/app_config';
import Session          from '@/shared/services/session';
import HasDocuments     from '@/shared/mixins/has_documents';
import HasTranslations  from '@/shared/mixins/has_translations';
import EventBus         from '@/shared/services/event_bus';
import I18n             from '@/i18n';
import NullGroupModel   from '@/shared/models/null_group_model';
import { addDays, startOfHour, differenceInHours, addHours } from 'date-fns';
import { snakeCase, compact, head, orderBy, sortBy, map, flatten, slice, uniq, isEqual, shuffle } from 'lodash-es';

export default class PollModel extends BaseModel {
  static singular = 'poll';
  static plural = 'polls';
  static uniqueIndices = ['id', 'key'];
  static indices = ['discussionId', 'authorId', 'groupId'];

  constructor(...args) {
    super(...args);
    this.close = this.close.bind(this);
    this.reopen = this.reopen.bind(this);
    this.addToThread = this.addToThread.bind(this);
    this.addOption = this.addOption.bind(this);
    this.poll = this.poll.bind(this);
  }

  afterConstruction() {
    HasDocuments.apply(this, {showTitle: true});
    return HasTranslations.apply(this);
  }

  config() {
    return AppConfig.pollTypes[this.pollType];
  }

  i18n() {
    return AppConfig.pollTypes[this.pollType].i18n;
  }

  pollTypeKey() {
    return `poll_types.${this.pollType}`;
  }

  poll() { return this; }

  defaultValues() {
    return {
      discussionId: null,
      title: '',
      titlePlaceholder: null,
      closingAt: null,
      customize: false,
      details: '',
      detailsFormat: 'html',
      decidedVotersCount: 0,
      defaultDurationInDays: null,
      specifiedVotersOnly: false,
      pollOptionNames: [],
      pollType: 'proposal',
      chartColumn: null,
      chartType: null,
      minScore: null,
      maxScore: null,
      minimumStanceChoices: null,
      maximumStanceChoices: null,
      dotsPerPerson: null,
      canRespondMaybe: true,
      meetingDuration: null,
      limitReasonLength: true,
      stanceReasonRequired: 'optional',
      reasonPrompt: null,
      files: [],
      imageFiles: [],
      attachments: [],
      linkPreviews: [],
      notifyOnClosingSoon: 'undecided_voters',
      results: [],
      pollTemplateId: null,
      pollTempalteKey: null,
      pollOptionIds: [],
      pollOptionNameFormat: null,
      recipientMessage: null,
      recipientAudience: null,
      recipientUserIds: [],
      recipientChatbotIds: [],
      recipientEmails: [],
      notifyRecipients: true,
      shuffleOptions: false,
      tags: [],
      hideResults: 'off',
      stanceCounts: []
    };
  }

  pollTemplateKeyOrId() {
    return this.pollTemplateId || this.pollTemplateKey;
  }
  
  clonePoll() {
    const clone = this.clone();
    clone.id = null;
    clone.key = null;
    clone.sourceTemplateId = this.id;
    clone.authorId = Session.user().id;
    clone.groupId = null;
    clone.discussionId = null;

    clone.template = false;
    clone.closingAt = startOfHour(addDays(new Date(), this.defaultDurationInDays || 7));

    if (this.pollOptionsAttributes) {
      clone.pollOptionsAttributes = this.pollOptionsAttributes;
    } else {
      clone.pollOptionsAttributes = this.pollOptions().map(o => {
          return {
            name: o.name,
            meaning: o.meaning,
            prompt: o.prompt,
            icon: o.icon
          };
      });
    }

    clone.closedAt = null;
    clone.createdAt = null;
    clone.updatedAt = null;
    clone.decidedVotersCount = null;
    clone.undecidedVotersCount = null;
    return clone;
  }

  clonePollOptions() {
    return this.pollOptions().map(o => {
      return {
        id: o.id,
        name: o.name,
        meaning: o.meaning,
        prompt: o.prompt,
        icon: o.icon
      };
    });
  }

  defaulted(attr) {
    if (this[attr] === null) {
      return AppConfig.pollTypes[this.pollType].defaults[snakeCase(attr)];
    } else {
      return this[attr];
    }
  }

  audienceValues() {
    return {name: this.group().name};
  }

  relationships() {
    this.belongsTo('author', {from: 'users'});
    this.belongsTo('discussion');
    this.belongsTo('group');
    this.hasMany('stances');
    return this.hasMany('versions');
  }

  pieSlices() {
    let slices = [];
    if ((this.pollType === 'count') && this.results.find(r => r.icon === 'agree')) {
      const agree = this.results.find(r => r.icon === 'agree');
      if (agree.score < this.agreeTarget) {
        const pct = (parseFloat(agree.score) / parseFloat(this.agreeTarget)) * 100;
        slices.push({
          value: pct,
          color: agree.color
        });
        slices.push({
          value: 100 - pct,
          color: "#ddd"
        });
      } else {
        slices.push({
          value: 100,
          color: agree.color
        });
      }
    } else {
      slices = this.results.filter(r => r[this.chartColumn]).map(r => {
        return {
          value: r[this.chartColumn],
          color: r.color
        };
      });
    }
    return slices;
  }

  pollOptions() {
    const options = (this.recordStore.pollOptions.collection.chain().find({pollId: this.id, id: {$in: this.pollOptionIds}}).data());
    return orderBy(options, 'priority');
  }

  pollOptionsForVoting() {
    if (this.shuffleOptions) {
      return shuffle(this.pollOptions());
    } else {
      return this.pollOptions();
    }
  }

  bestNamedId() {
    return ((this.id && this) || (this.discusionId && this.discussion()) || (this.groupId && this.group()) || {namedId() {}}).namedId();
  }

  voters() {
    return this.latestStances().map(stance => stance.participant());
  }

  members() {
    return ((this.group() && this.group().members()) || []).concat(this.voters());
  }

  participantIds() {
    return compact(flatten(
      [this.authorId],
      map(this.stances(), 'participantId')
    )
    );
  }

  adminsInclude(user) {
    const stance = this.stanceFor(user);
    return ((this.authorId === user.id) && !this.groupId) ||
    ((this.authorId === user.id) && (this.groupId && this.group().membersInclude(user))) ||
    ((this.authorId === user.id) && (this.discussionId && this.discussion().membersInclude(user))) ||
    (stance && stance.admin) || 
    (this.discussionId && this.discussion().adminsInclude(user)) || 
    this.group().adminsInclude(user);
  }

  votersInclude(user) {
    if (specifiedVotersOnly) {
      return this.stanceFor(user);
    } else {
      return this.membersInclude(user);
    }
  }

  membersInclude(user) {
    return this.stanceFor(user) || (this.discussionId && this.discussion().membersInclude(user)) || this.group().membersInclude(user);
  }

  stanceFor(user) {
    if (user.id === AppConfig.currentUserId) {
      return this.myStance(); 
    } else {
      return head(orderBy(this.recordStore.stances.find({pollId: this.id, participantId: user.id, latest: true, revokedAt: null}), 'createdAt', 'desc'));
    }
  }

  myStance() {
    return this.recordStore.stances.find({id: this.myStanceId, revokedAt: null})[0];
  }

  iHaveVoted() {
    return this.myStanceId && this.myStance() && this.myStance().castAt;
  }

  showResults() {
    return !!this.closingAt &&
    (() => { switch (this.hideResults) {
      case "until_closed":
        return this.closedAt;
      case "until_vote":
        return this.closedAt || this.iHaveVoted();
      default:
        return true;
    } })();
  }

  optionsDiffer(options) {
    return !isEqual(sortBy(this.pollOptionNames), sortBy(map(options, 'name')));
  }

  iCanVote() {
    return this.isVotable() && (this.myStance() || (!this.specifiedVotersOnly && this.membersInclude(Session.user())));
  }

  isBlank() {
    return (this.details === '') || (this.details === null) || (this.details === '<p></p>');
  }

  authorName() {
    return this.author().nameWithTitle(this.group());
  }

  reactions() {
    return this.recordStore.reactions.find({reactableId: this.id, reactableType: "Poll"});
  }

  decidedVoterIds() {
    return uniq(flatten(this.results.map(o => o.voter_ids)));
  }

  // who's voted?
  decidedVoters() {
    return this.recordStore.users.find(this.decidedVoterIds());
  }

  outcome() {
    return this.recordStore.outcomes.find({pollId: this.id, latest: true})[0];
  }

  createdEvent() {
    return this.recordStore.events.find({eventableId: this.id, kind: 'poll_created'})[0];
  }

  latestStances(order, limit) {
    if (order == null) { order = '-createdAt'; }
    return slice(sortBy(this.recordStore.stances.find({pollId: this.id, latest: true, revokedAt: null}), order), 0, limit);
  }

  latestCastStances() {
    return this.recordStore.stances.collection.chain().find({
      pollId: this.id,
      latest: true,
      revokedAt: null,
      castAt: {$ne: null}
    }).data();
  }

  isVotable() {
    return !this.discardedAt && this.closingAt && (this.closedAt == null);
  }

  isClosed() {
    return (this.closedAt != null);
  }

  close() {
    this.processing = true;
    return this.remote.postMember(this.key, 'close')
    .finally(() => { return this.processing = false; });
  }

  reopen() {
    this.processing = true;
    return this.remote.postMember(this.key, 'reopen', {poll: {closing_at: this.closingAt}})
    .finally(() => { return this.processing = false; });
  }

  addToThread(discussionId) {
    this.processing = true;
    return this.remote.patchMember(this.keyOrId(), 'add_to_thread', { discussion_id: discussionId })
    .finally(() => { return this.processing = false; });
  }

  notifyAction() {
    if (this.isNew()) {
      return 'publish';
    } else {
      return 'edit';
    }
  }

  translatedPollType() {
    return I18n.t(`poll_types.${this.pollType}`);
  }

  translatedPollTypeCaps() {
    return I18n.t(`decision_tools_card.${this.pollType}_title`);
  }

  addOption(option) {
    if (this.pollOptionNames.includes(option) || !option) { return false; }
    this.pollOptionNames.push(option);
    if (this.pollType === "meeting") { this.pollOptionNames.sort(); }
    return option;
  }

  hasVariableScore() { 
    return this.defaulted('minScore') !== this.defaulted('maxScore');
  }

  singleChoice() {
    let middle;
    return this.defaulted('minimumStanceChoices') === (middle = this.defaulted('maximumStanceChoices')) && middle === 1;
  }

  hasOptionIcon() { 
    return this.config().has_option_icon;
  }

  datesAsOptions() {
    return this.pollOptionNameFormat === 'iso8601';
  }

  removeOrphanOptions() {
    return this.pollOptions().forEach(option => {
      if (!this.pollOptionNames.includes(option.name)) { return option.remove(); }
    });
  }
};
