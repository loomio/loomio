// Browser device details are deliberately coarse: passkeys may sync between
// devices, so this provides a recognizable label without implying exclusivity.
export const passkeyPlatformName = (browserNavigator = globalThis.navigator) => {
  const platform = browserNavigator?.userAgentData?.platform || browserNavigator?.platform || '';
  const userAgent = browserNavigator?.userAgent || '';

  if (/iPad|iPhone|iPod/i.test(platform) || /iPad|iPhone|iPod/i.test(userAgent)) return 'iPhone or iPad';
  if (platform === 'MacIntel' && browserNavigator?.maxTouchPoints > 1) return 'iPhone or iPad';
  if (/Android/i.test(platform) || /Android/i.test(userAgent)) return 'Android';
  if (/CrOS|Chrome OS/i.test(platform) || /CrOS/i.test(userAgent)) return 'ChromeOS';
  if (/Mac/i.test(platform)) return 'Mac';
  if (/Win/i.test(platform)) return 'Windows';
  if (/Linux/i.test(platform)) return 'Linux';
};

