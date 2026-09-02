export function isStandalone(browserWindow, browserNavigator) {
  return browserWindow.matchMedia?.('(display-mode: standalone)').matches === true ||
    browserNavigator.standalone === true;
}

export function isIosSafari(browserNavigator) {
  const userAgent = browserNavigator.userAgent || '';
  const platform = browserNavigator.platform || '';
  const isIos = /iPad|iPhone|iPod/.test(userAgent) ||
    (platform === 'MacIntel' && browserNavigator.maxTouchPoints > 1);
  const isAlternativeIosBrowser = /CriOS|FxiOS|EdgiOS|OPiOS|DuckDuckGo/.test(userAgent);

  return isIos && /Safari/.test(userAgent) && !isAlternativeIosBrowser;
}

export function createPwaState(browserWindow, browserNavigator) {
  const installed = isStandalone(browserWindow, browserNavigator);

  return {
    installPrompt: null,
    installed,
    iosInstallAvailable: !installed && isIosSafari(browserNavigator),
    nativeInstallAvailable: false,
    workerUpdateAvailable: false,
  };
}

export function serviceWorkerUrl(version, release) {
  const params = [];
  if (version) params.push(`version=${encodeURIComponent(version)}`);
  if (release) params.push(`release=${encodeURIComponent(release)}`);
  return `/service-worker.js${params.length ? `?${params.join('&')}` : ''}`;
}

// Coordinates install-prompt state and worker activation without depending on Vue,
// so first installs and updates follow the same rules in every caller.
export function createPwaLifecycle({
  browserWindow,
  browserNavigator,
  state,
  onUpdateAvailable = () => {},
}) {
  let installListenersStarted = false;
  let controllerListenerStarted = false;
  let registration = null;
  let waitingWorker = null;
  let reloadOnControllerChange = false;
  let updateActivatedElsewhere = false;
  const watchedWorkers = new Set();

  function startInstallListeners() {
    if (installListenersStarted) return;
    installListenersStarted = true;

    browserWindow.addEventListener('beforeinstallprompt', event => {
      event.preventDefault();
      if (state.installed) return;

      state.installPrompt = event;
      state.nativeInstallAvailable = true;
      state.iosInstallAvailable = false;
    });

    browserWindow.addEventListener('appinstalled', () => {
      state.installPrompt = null;
      state.installed = true;
      state.iosInstallAvailable = false;
      state.nativeInstallAvailable = false;
    });
  }

  async function promptInstall() {
    const prompt = state.installPrompt;
    if (!prompt) return null;

    try {
      await prompt.prompt();
      return await prompt.userChoice;
    } finally {
      // A BeforeInstallPromptEvent can only be used once, including when the
      // user dismisses it. Wait for a new event before offering the button again.
      state.installPrompt = null;
      state.nativeInstallAvailable = false;
    }
  }

  function announceUpdate(worker) {
    if (!browserNavigator.serviceWorker.controller || !worker || waitingWorker === worker) return;

    waitingWorker = worker;
    updateActivatedElsewhere = false;
    state.workerUpdateAvailable = true;
    onUpdateAvailable(registration);
  }

  function watchWorker(worker) {
    if (!worker || watchedWorkers.has(worker)) return;
    watchedWorkers.add(worker);

    if (worker.state === 'installed') announceUpdate(worker);
    worker.addEventListener('statechange', () => {
      if (worker.state === 'installed') announceUpdate(worker);
    });
  }

  function watchRegistration(value) {
    registration = value;
    if (!registration) return;

    if (!controllerListenerStarted) {
      controllerListenerStarted = true;
      browserNavigator.serviceWorker.addEventListener('controllerchange', () => {
        if (!reloadOnControllerChange) {
          updateActivatedElsewhere = state.workerUpdateAvailable;
          return;
        }
        reloadOnControllerChange = false;
        browserWindow.location.reload();
      });
    }

    announceUpdate(registration.waiting);
    watchWorker(registration.installing);
    registration.addEventListener('updatefound', () => watchWorker(registration.installing));
  }

  function activateUpdate() {
    if (updateActivatedElsewhere) return false;
    const worker = registration?.waiting || waitingWorker;
    if (!worker) return false;

    reloadOnControllerChange = true;
    try {
      worker.postMessage({ type: 'SKIP_WAITING' });
      return true;
    } catch (_error) {
      reloadOnControllerChange = false;
      return false;
    }
  }

  return {
    activateUpdate,
    promptInstall,
    startInstallListeners,
    watchRegistration,
  };
}
