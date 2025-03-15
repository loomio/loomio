import { register } from 'register-service-worker'
import Records from "@/shared/services/records";
import * as dummy from "@/service_worker"

export default function registerServiceWorker() {
  register(`/src/service_worker.js`, {
    registrationOptions: { scope: '/src/', type: 'module' },
    ready() {
      console.log(
          'App is being served from cache by a service worker.\n' +
          'For more details, visit https://goo.gl/AFskqB'
      )
    },
    registered(registration) {
      console.log('Service worker has been registered.')

      Notification.requestPermission().then( p => {
        if(p !== 'granted') {
          console.log('Service worker push permissions denied.');
          return;
        }

        //At the time of writing, having a cookie is the only reliable way to detect if push registration happened before
        //Should be changed to this as soon as there is better support: https://developer.mozilla.org/en-US/docs/Web/API/Notification/permission_static
        const deviceHasNotifications = document.cookie
            .split("; ")
            .find((row) => row.startsWith("hasPushNotifications="))
            ?.split("=")[1];

        if(deviceHasNotifications === 'true') {
          console.log('Cookie state: Push Notifications already registered on this device. Clear cookies to reregister.')
          return;
        }

          Records.remote.get('/webpush').then(data => {
          window.vapidPublicKey =  data.webpush_certs[0].public_key
          registration.pushManager.subscribe({userVisibleOnly: true, applicationServerKey: window.vapidPublicKey}).then(s => {
            Records.remote.post('/webpush', s.toJSON()).then(response => {
              if(response) {
                document.cookie = "hasPushNotifications=true";
                console.log('Successfully registered push subscription.')
              }
            });
          });
        });
      });
    },/*
    cached() {
      console.log('Content has been cached for offline use.')
    },
    updatefound() {
      console.log('New content is downloading.')
    },
    updated() {
      console.log('New content is available; please refresh.')
    },
    offline() {
      console.log('No internet connection found. App is running in offline mode.')
    },
    error(error) {
      console.error('Error during service worker registration:', error)
    }*/
  })
}

