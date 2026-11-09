// Gives the page a virtual passkey authenticator. It lives on the page's
// DevTools session and is discarded with the page.
export async function addPasskeyAuthenticator(page) {
  const client = await page.context().newCDPSession(page);
  await client.send('WebAuthn.enable');
  await client.send('WebAuthn.addVirtualAuthenticator', {
    options: { protocol: 'ctap2', transport: 'usb', hasResidentKey: true, hasUserVerification: true, isUserVerified: true }
  });
  // The app hides a failed passkey ceremony as if it were cancelled. Log the
  // browser's error, so a failing test's trace shows it.
  await page.addInitScript(() => {
    const create = navigator.credentials.create.bind(navigator.credentials);
    navigator.credentials.create = (...args) => create(...args).catch(error => {
      console.error(`WebAuthn create failed: ${error.name}: ${error.message}`);
      throw error;
    });
  });
}

// Makes the browser report no passkey support.
export async function withoutPasskeys(page) {
  await page.addInitScript(() => Object.defineProperty(window, 'PublicKeyCredential', { value: undefined, configurable: true }));
}
