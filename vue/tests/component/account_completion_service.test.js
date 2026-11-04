import { beforeEach, describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({
  user: null,
  isSignedIn: vi.fn(),
  emit: vi.fn()
}));

vi.mock('@/shared/services/session', () => ({default: {
  user: () => mocks.user,
  isSignedIn: mocks.isSignedIn
}}));
vi.mock('@/shared/services/event_bus', () => ({default: {$emit: mocks.emit}}));

import AccountCompletionService from '@/shared/services/account_completion_service';

describe('account completion on page boot', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mocks.isSignedIn.mockReturnValue(true);
    mocks.user = {name: 'Returning Person', legalAcceptanceRequired: false};
  });

  it.each([null, '', ' \t '])('asks a signed-in user with name %j to complete their profile', async name => {
    mocks.user.name = name;
    const completion = AccountCompletionService.maybeOpen();

    expect(mocks.emit).toHaveBeenCalledWith('openModal', {
      component: 'AccountCompletion',
      props: {user: mocks.user, completed: expect.any(Function)},
      maxWidth: 560,
      persistent: true
    });
    mocks.emit.mock.calls[0][1].props.completed();
    await expect(completion).resolves.toBe(true);
  });

  it('does not ask a signed-out visitor to complete a profile', async () => {
    mocks.isSignedIn.mockReturnValue(false);
    mocks.user.name = null;

    await expect(AccountCompletionService.maybeOpen()).resolves.toBe(false);
    expect(mocks.emit).not.toHaveBeenCalled();
  });

  it('does not interrupt a returning user whose profile is complete', async () => {
    await expect(AccountCompletionService.maybeOpen()).resolves.toBe(false);
    expect(mocks.emit).not.toHaveBeenCalled();
  });

  it('still asks for legal acceptance when the server requires it', () => {
    mocks.user.legalAcceptanceRequired = true;

    AccountCompletionService.maybeOpen();

    expect(mocks.emit.mock.calls[0][1].component).toBe('AccountCompletion');
  });
});
