export function requiresHomeScreen(browserWindow, browserNavigator) {
  const userAgent = browserNavigator.userAgent || '';
  const platform = browserNavigator.platform || '';
  const isIos = /iPad|iPhone|iPod/.test(userAgent) ||
    (platform === 'MacIntel' && browserNavigator.maxTouchPoints > 1);
  const isStandalone = browserWindow.matchMedia?.('(display-mode: standalone)').matches === true ||
    browserNavigator.standalone === true;

  return isIos && !isStandalone;
}
