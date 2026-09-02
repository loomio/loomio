// Browser push cleanup is best-effort. Server logout must start immediately so
// a stalled service-worker or PushManager operation cannot retain the session.
export function signOutSession({ clearCurrentUser, destroySession, disableBrowser, reload }) {
  try {
    Promise.resolve(disableBrowser()).catch(() => {});
  } catch (_error) {
    // Continue with server logout when browser cleanup fails synchronously.
  }

  clearCurrentUser();
  return destroySession().then(reload);
}
