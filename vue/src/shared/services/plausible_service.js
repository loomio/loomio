import Plausible from 'plausible-tracker';
import AppConfig from '@/shared/services/app_config';

let plausible = null;

export default new class PlausibleService {
  boot() {
    if (AppConfig.plausible_site) {
      const u = new URL(AppConfig.plausible_src);
      return plausible = Plausible({
        domain: AppConfig.plausible_site,
        apiHost: u.origin,
        trackLocalhost: true
      });
    }
  }

  trackPageview() {
    if (plausible) {
      return plausible.trackPageview();
    }
  }

  trackEvent(name) {
    if (plausible) {
      return plausible.trackEvent(name);
    }
  }
};
