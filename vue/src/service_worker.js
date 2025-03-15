import {ExpirationPlugin} from 'workbox-expiration';
import {createHandlerBoundToURL, precacheAndRoute, cleanupOutdatedCaches} from 'workbox-precaching';
import {registerRoute} from 'workbox-routing';
import {CacheFirst} from 'workbox-strategies';
import { CacheableResponsePlugin } from 'workbox-cacheable-response/CacheableResponsePlugin';


// Register precache routes (static cache)
precacheAndRoute(self.__WB_MANIFEST || []);

// Clean up old cache
cleanupOutdatedCaches();

// Google fonts dynamic cache
registerRoute(
    /^https:\/\/fonts\.googleapis\.com\/.*/i,
    new CacheFirst({
        cacheName: "google-fonts-cache",
        plugins: [
            new ExpirationPlugin({maxEntries: 500, maxAgeSeconds: 5184e3}),
            new CacheableResponsePlugin({statuses: [0, 200]})
        ]
    }), "GET");

// Google fonts dynamic cache
registerRoute(
    /^https:\/\/fonts\.gstatic\.com\/.*/i, new CacheFirst({
        cacheName: "gstatic-fonts-cache",
        plugins: [
            new ExpirationPlugin({maxEntries: 500, maxAgeSeconds: 5184e3}),
            new CacheableResponsePlugin({statuses: [0, 200]})
        ]
    }), "GET");

// Dynamic cache for images from `/storage/`
registerRoute(
    /.*storage.*/, new CacheFirst({
        cacheName: "dynamic-images-cache",
        plugins: [
            new ExpirationPlugin({maxEntries: 500, maxAgeSeconds: 5184e3}),
            new CacheableResponsePlugin({statuses: [0, 200]})
        ]
    }), "GET");

// Install and activate service worker
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', () => self.clients.claim());

// On push notification from server
self.addEventListener('push', function (e) {
    if (!(
        self.Notification &&
        self.Notification.permission === 'granted'
    )) {
        console.log('Push notification unsupported or denied.')
        return;
    }

    if (e.data) {
        const message = e.data.json();
        const options = {
            title: message.title,
            body: message.body,
            icon: message.iconUrl,
            timestamp: message.timestamp,
            actions: [{
                title: message.openToVerb,
                action: message.openTo
            }]
        }

        e.waitUntil(self.registration.showNotification(message.title, options));
    }
});

// Click and open notification
self.addEventListener('notificationclick', function(event) {
    event.notification.close();
    if(event.action) {
        clients.openWindow('/../' + event.action); // Open link from action
    }
}, false);