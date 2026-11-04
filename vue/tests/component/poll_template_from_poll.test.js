import { shallowMount, flushPromises } from '@vue/test-utils';
import { beforeEach, afterEach, describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({
  signedIn: true,
  user: {id: 2},
  buildTemplate: vi.fn(),
  buildPoll: vi.fn(),
  fetchPoll: vi.fn(),
  findTopicItems: vi.fn(),
  fetchTopicItems: vi.fn(),
  emit: vi.fn()
}));

vi.mock('@/shared/services/records', () => ({default: {
  pollTemplates: {build: mocks.buildTemplate},
  polls: {build: mocks.buildPoll, findOrFetchById: mocks.fetchPoll},
  topicItems: {find: mocks.findTopicItems, fetch: mocks.fetchTopicItems}
}}));
vi.mock('@/shared/services/session', () => ({default: {
  user: () => mocks.user,
  isSignedIn: () => mocks.signedIn,
  returnTo: () => '/p/source'
}}));
vi.mock('@/shared/services/app_config', () => ({default: {
  pollTypes: {proposal: {}, stv: {}},
  templateSettings: {
    poll_template: ['poll_type', 'title', 'details', 'details_format', 'anonymous', 'weighted_voting',
      'hide_results', 'specified_voters_only', 'quorum_pct', 'stance_reason_required',
      'notify_on_open', 'tags', 'poll_options', 'attachments_admin_only', 'stv_seats', 'stv_method', 'stv_quota'],
    poll_option: ['name', 'meaning', 'prompt', 'icon', 'priority', 'test_operator', 'test_percent', 'test_against']
  }
}}));
vi.mock('@/i18n', () => ({I18n: {global: {t: key => key}}}));
vi.mock('@/shared/services/ability_service', () => ({default: {}}));
vi.mock('@/shared/services/flash', () => ({default: {}}));
vi.mock('@/shared/services/bookmark_service', () => ({default: {actions: () => ({})}}));
vi.mock('@/shared/services/event_bus', () => ({default: {$emit: mocks.emit}}));
vi.mock('@/components/poll_template/form', () => ({default: {
  name: 'PollTemplateForm', props: ['pollTemplate'], template: '<div />'
}}));

import PollModel from '@/shared/models/poll_model';
import PollTemplateModel from '@/shared/models/poll_template_model';
import PollService from '@/shared/services/poll_service';
import PollTemplateFormPage from '@/components/poll_template/form_page.vue';

let source;
let group;
let topic;
let creationItem;
let options;
let wrapper;

beforeEach(() => {
  vi.clearAllMocks();
  mocks.signedIn = true;
  group = {id: 7, membersCanCreateTemplates: false, adminsInclude: () => true, membersInclude: () => true};
  topic = {topicableType: 'Discussion', topicableId: 12,
    allowComments: false, allowReactions: false, commentLengthMax: 300, attachmentsAdminOnly: true,
    tags: ['Bargaining', 'Other thread category']};
  creationItem = {tags: ['Bargaining']};
  mocks.findTopicItems.mockReturnValue([creationItem]);
  mocks.fetchTopicItems.mockImplementation(async () => {
    mocks.findTopicItems.mockReturnValue([creationItem]);
  });
  options = [{id: 30, pollId: 10, name: 'Consent', meaning: 'I support this proposal',
    prompt: 'Any concerns?', icon: 'consent', priority: 0, testOperator: 'gte',
    testPercent: 80, testAgainst: 'score_percent', totalScore: 4, voterIds: [5]}];
  source = new PollModel({id: 10, key: 'source', groupId: 7, topicId: 8, authorId: 1,
    title: 'Consent proposal', details: '<p>Proposed changes</p>', detailsFormat: 'html',
    openedAt: new Date(2026, 9, 20), closingAt: new Date(2026, 9, 23),
    voteCountCast: 4, results: [{voter_ids: [5]}], quorumPct: 60, stvMethod: null, stvQuota: null,
    tags: [],
    stanceReasonRequired: 'required_for_disagree_or_block'});
  source.group = () => group;
  source.topic = () => topic;
  source.pollOptions = () => options;
  mocks.buildTemplate.mockImplementation(attrs => new PollTemplateModel(attrs));
  mocks.buildPoll.mockImplementation(() => new PollModel());
  mocks.fetchPoll.mockResolvedValue(source);
});

afterEach(() => wrapper?.unmount());

describe('saving a poll as a template', () => {
  it.each(['off', 'until_vote', 'until_closed'])('copies reusable content and %s result visibility without poll state', hideResults => {
    source.hideResults = hideResults;
    const template = source.buildTemplate();

    expect(template).toMatchObject({groupId: 7, processName: source.title, title: source.title,
      details: source.details, detailsFormat: 'html', quorumPct: 60,
      stanceReasonRequired: source.stanceReasonRequired, defaultDurationInDays: 3,
      hideResults, allowComments: false, allowReactions: false, commentLengthMax: 300, attachmentsAdminOnly: true,
      tags: ['Bargaining']});
    expect(template.isNew()).toBe(true);
    for (const field of ['id', 'key', 'topicId', 'authorId', 'openedAt', 'openingAt', 'closingAt',
      'closedAt', 'results', 'voteCountCast', 'voterIds', 'stvResults']) {
      expect(template.attributeNames).not.toContain(field);
    }
    expect(template.pollOptions).toEqual([{name: 'Consent', meaning: options[0].meaning,
      prompt: options[0].prompt, icon: 'consent', priority: 0,
      test_operator: 'gte', test_percent: 80, test_against: 'score_percent'}]);
    template.tags.push('Template only');
    template.pollOptions[0].meaning = 'Revised meaning';
    expect(source.tags).toEqual([]);
    expect(creationItem.tags).toEqual(['Bargaining']);
    expect(topic.tags).toEqual(['Bargaining', 'Other thread category']);
    expect(options[0].meaning).toBe('I support this proposal');
    expect(template.stvMethod).toBe('scottish');
    expect(template.stvQuota).toBe('droop');
  });

  it('keeps anonymous settings and creates a fresh poll from the saved configuration', () => {
    source.anonymous = true;
    source.hideResults = 'until_closed';
    source.stanceReasonRequired = 'disabled';
    source.anonymousBallotSubmitted = true;
    const template = source.buildTemplate();
    template.id = 9;
    const poll = template.buildPoll();

    expect(poll).toMatchObject({anonymous: true, hideResults: 'until_closed',
      stanceReasonRequired: 'disabled', pollTemplateId: 9, groupId: 7, attachmentsAdminOnly: true,
      openingAt: null, openedAt: null, anonymousBallotSubmitted: false, voteCountCast: 0});
    expect(poll.pollOptionsAttributes[0]).toMatchObject({meaning: options[0].meaning,
      prompt: options[0].prompt, testOperator: 'gte', testPercent: 80});
  });

  it('retains weighted and STV configuration without election results', () => {
    Object.assign(source, {pollType: 'stv', weightedVoting: true, stvSeats: 3,
      stvMethod: 'meek', stvQuota: 'hare', stvResults: {elected: [30]}});
    expect(source.buildTemplate()).toMatchObject({pollType: 'stv', weightedVoting: true,
      stvSeats: 3, stvMethod: 'meek', stvQuota: 'hare'});
  });

  it.each([
    ['group admin', true, true, false, true, true],
    ['member with permission', true, false, true, true, true],
    ['member without permission', true, false, false, true, false],
    ['thread admin or guest without membership', true, false, true, false, false],
    ['signed-out visitor', false, false, true, false, false],
    ['nonmember', true, false, false, false, false]
  ])('replaces the copy action and respects template creation for a %s', (_role, signedIn, admin, enabled, member, allowed) => {
    mocks.signedIn = signedIn;
    Object.assign(group, {membersCanCreateTemplates: enabled, adminsInclude: () => admin, membersInclude: () => member});
    const actions = PollService.actions(source);
    expect(actions).not.toHaveProperty('make_a_copy');
    expect(actions.save_as_template.canPerform()).toBe(allowed);
    expect(actions.save_as_template.name).toBe('common.action.save_as_template');
    expect(actions.save_as_template.to()).toEqual({path: '/poll_templates/new', query: {poll_id: 10, return_to: '/p/source'}});
  });

  it('does not offer templates for direct or discarded polls', () => {
    group.id = null;
    expect(PollService.actions(source).save_as_template.canPerform()).toBe(false);
    group.id = 7;
    source.discardedAt = new Date();
    expect(PollService.actions(source).save_as_template.canPerform()).toBe(false);
  });
});

describe('template form loaded from a poll', () => {
  async function mountPage() {
    wrapper = shallowMount(PollTemplateFormPage, {global: {
      mocks: {$route: {params: {}, query: {poll_id: '10'}}},
      stubs: {VMain: {template: '<main><slot /></main>'}, VContainer: {template: '<div><slot /></div>'}}
    }});
    await flushPromises();
  }

  it('loads the source poll into a new template', async () => {
    await mountPage();
    const template = wrapper.findComponent({name: 'PollTemplateForm'}).props('pollTemplate');
    expect(template.isNew()).toBe(true);
    expect(template.processName).toBe(source.title);
    expect(template.tags).toEqual(['Bargaining']);
    expect(mocks.fetchPoll).toHaveBeenCalledWith(10);
    expect(mocks.fetchTopicItems).not.toHaveBeenCalled();
  });

  it.each(['Poll', 'Discussion'])('fetches a missing creation item for a %s topic before building the template', async topicableType => {
    Object.assign(topic, {topicableType, topicableId: topicableType === 'Poll' ? source.id : 12});
    mocks.findTopicItems.mockReturnValue([]);
    await mountPage();
    const params = {poll_key: 'source', kind: 'poll_created', per: 1};
    if (topicableType === 'Discussion') { params.unread_or_newest = 1; }
    expect(mocks.fetchTopicItems).toHaveBeenCalledWith({params});
    expect(wrapper.findComponent({name: 'PollTemplateForm'}).props('pollTemplate').tags).toEqual(['Bargaining']);
  });

  it('waits for the missing creation item before showing the form', async () => {
    mocks.findTopicItems.mockReturnValue([]);
    let resolveFetch;
    mocks.fetchTopicItems.mockReturnValue(new Promise(resolve => { resolveFetch = resolve; }));
    await mountPage();
    expect(wrapper.findComponent({name: 'PollTemplateForm'}).exists()).toBe(false);
    mocks.findTopicItems.mockReturnValue([creationItem]);
    resolveFetch();
    await flushPromises();
    expect(wrapper.findComponent({name: 'PollTemplateForm'}).props('pollTemplate').tags).toEqual(['Bargaining']);
  });

  it('copies an empty tag list from the creation item', async () => {
    creationItem.tags = [];
    source.tags = ['Stale poll tags'];
    await mountPage();
    expect(wrapper.findComponent({name: 'PollTemplateForm'}).props('pollTemplate').tags).toEqual([]);
  });

  it('rejects a manually entered route when the member cannot create templates', async () => {
    group.adminsInclude = () => false;
    await mountPage();
    expect(mocks.emit).toHaveBeenCalledWith('pageError', expect.objectContaining({status: 403}));
    expect(mocks.buildTemplate).not.toHaveBeenCalled();
    expect(mocks.fetchTopicItems).not.toHaveBeenCalled();
  });

  it.each([403, 404])('shows a source poll HTTP %s error without building a template', async status => {
    mocks.fetchPoll.mockRejectedValue(Object.assign(new Error('Unavailable'), {status}));
    await mountPage();
    expect(mocks.emit).toHaveBeenCalledWith('pageError', expect.objectContaining({status}));
    expect(mocks.buildTemplate).not.toHaveBeenCalled();
    expect(mocks.fetchTopicItems).not.toHaveBeenCalled();
  });

  it.each([403, 404])('shows a creation item HTTP %s error without building a template', async status => {
    mocks.findTopicItems.mockReturnValue([]);
    mocks.fetchTopicItems.mockRejectedValue(Object.assign(new Error('Unavailable'), {status}));
    await mountPage();
    expect(mocks.emit).toHaveBeenCalledWith('pageError', expect.objectContaining({status}));
    expect(mocks.buildTemplate).not.toHaveBeenCalled();
  });
});
