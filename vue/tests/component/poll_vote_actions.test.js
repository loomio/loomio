import { beforeEach, describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({
  canVerifyParticipants: vi.fn(),
  canAddMembersPoll: vi.fn(),
  openModal: vi.fn()
}));

vi.mock('@/shared/services/ability_service', () => ({default: {
  canVerifyParticipants: mocks.canVerifyParticipants,
  canAddMembersPoll: mocks.canAddMembersPoll
}}));
vi.mock('@/shared/services/bookmark_service', () => ({default: {actions: () => ({})}}));
vi.mock('@/shared/helpers/open_modal', () => ({default: mocks.openModal}));

import PollService from '@/shared/services/poll_service';

function pollActions(overrides = {}) {
  const poll = {
    key: 'poll123',
    anonymous: false,
    decidedVotersCount: 1,
    discardedAt: null,
    closedAt: null,
    openedAt: '2026-09-24T00:00:00Z',
    openingAt: null,
    config: () => ({has_options: true}),
    ...overrides
  };
  return PollService.actions(poll);
}

describe('poll vote actions', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('opens identified votes when votes exist, including after the poll closes', () => {
    const actions = pollActions({closedAt: '2026-09-25T00:00:00Z'});
    expect(actions.view_votes.name).toBe('poll_common.view_votes');
    expect(actions.view_votes.canPerform()).toBe(true);
    expect(actions.view_votes.to()).toBe('/p/poll123/votes');
    expect(actions.view_votes.dock).toBe(2);
    expect(pollActions({decidedVotersCount: 0}).view_votes.canPerform()).toBe(false);
    expect(pollActions({discardedAt: '2026-09-25T00:00:00Z'}).view_votes.canPerform()).toBe(false);
  });

  it('shows anonymous votes only to participants allowed to verify them', () => {
    mocks.canVerifyParticipants.mockReturnValue(false);
    expect(pollActions({anonymous: true}).view_votes.canPerform()).toBe(false);

    mocks.canVerifyParticipants.mockReturnValue(true);
    expect(pollActions({anonymous: true, decidedVotersCount: 0}).view_votes.canPerform()).toBe(true);
  });

  it('opens voter management only for eligible coordinators while the poll is active', () => {
    mocks.canAddMembersPoll.mockReturnValue(true);
    const actions = pollActions();
    expect(actions.announce_poll.name).toBe('poll_common_form.manage_voters');
    expect(actions.announce_poll.canPerform()).toBe(true);
    actions.announce_poll.perform();
    expect(mocks.openModal).toHaveBeenCalledWith({
      component: 'PollMembers',
      props: {poll: expect.objectContaining({key: 'poll123'})}
    });
    expect(pollActions({closedAt: '2026-09-25T00:00:00Z'}).announce_poll.canPerform()).toBe(false);

    mocks.canAddMembersPoll.mockReturnValue(false);
    expect(pollActions().announce_poll.canPerform()).toBe(false);
  });
});
