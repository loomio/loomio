import { beforeEach, describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({save: vi.fn(), captureException: vi.fn(), custom: vi.fn()}));
vi.mock('@/shared/services/app_config', () => ({default: {}}));
vi.mock('@/shared/services/records', () => ({default: {
  registrations: {build: () => ({save: mocks.save})}
}}));
vi.mock('@/shared/services/session', () => ({default: {}}));
vi.mock('@/shared/services/event_bus', () => ({default: {}}));
vi.mock('@/shared/services/flash', () => ({default: {custom: mocks.custom}}));
vi.mock('@/shared/services/credential_prompt_service', () => ({default: {}}));
vi.mock('@/shared/services/account_completion_service', () => ({default: {}}));
vi.mock('@/shared/record_store/restful_client', () => ({default: class {}}));
vi.mock('@/i18n', () => ({I18n: {global: {t: key => key}}}));
vi.mock('@sentry/vue', () => ({captureException: mocks.captureException}));

import AuthService from '@/shared/services/auth_service';

const httpError = status => Object.assign(new Error(`HTTP ${status}: Registration failed`), {
  status, restfulClientError: true, httpMethod: 'POST', httpResource: 'registrations'
});

describe('signup error reporting', () => {
  let user;

  beforeEach(() => {
    vi.resetAllMocks();
    user = {email: 'new@example.com', errors: {}, update: vi.fn()};
  });

  it.each([500, 503])('reports HTTP %i to Sentry and shows the original error', async status => {
    const error = httpError(status);
    mocks.save.mockRejectedValueOnce(error);

    await AuthService.signUp(user);

    expect(mocks.captureException).toHaveBeenCalledExactlyOnceWith(error);
    expect(mocks.custom).toHaveBeenCalledWith(error.toString());
    expect(user.errors).toEqual({});
    expect(user.update).not.toHaveBeenCalled();
  });

  it('reports unexpected client exceptions', async () => {
    const error = new SyntaxError('Unexpected end of JSON input');
    mocks.save.mockRejectedValueOnce(error);

    await AuthService.signUp(user);

    expect(mocks.captureException).toHaveBeenCalledExactlyOnceWith(error);
    expect(mocks.custom).toHaveBeenCalledWith(error.toString());
    expect(user.update).not.toHaveBeenCalled();
  });

  it.each([401, 403, 422, 429])('does not report handled HTTP %i as an exception', async status => {
    const error = httpError(status);
    mocks.save.mockRejectedValueOnce(error);

    await AuthService.signUp(user);

    expect(mocks.captureException).not.toHaveBeenCalled();
    expect(mocks.custom).toHaveBeenCalledWith(error.toString());
    expect(user.errors).toEqual({});
    expect(user.update).not.toHaveBeenCalled();
  });

  it('does not report a connection failure as an exception', async () => {
    const error = Object.assign(new TypeError('Failed to fetch'), {networkError: true});
    mocks.save.mockRejectedValueOnce(error);

    await AuthService.signUp(user);

    expect(mocks.captureException).not.toHaveBeenCalled();
    expect(mocks.custom).toHaveBeenCalledWith(error.toString());
    expect(user.errors).toEqual({});
    expect(user.update).not.toHaveBeenCalled();
  });

  it.each([422, 500])('preserves field errors for HTTP %i, reporting server failures', async status => {
    const error = Object.assign(httpError(status), {errors: {email: ['Address rejected']}});
    mocks.save.mockRejectedValueOnce(error);

    await AuthService.signUp(user);

    expect(user.errors).toEqual({email: ['Address rejected']});
    expect(mocks.custom).not.toHaveBeenCalled();
    expect(mocks.captureException).toHaveBeenCalledTimes(status >= 500 ? 1 : 0);
    expect(user.update).not.toHaveBeenCalled();
  });
});
