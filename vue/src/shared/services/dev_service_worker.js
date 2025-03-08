import { registerSW } from 'virtual:pwa-register';

if ('serviceWorker' in navigator) {
    registerSW();
}