"use strict";
import * as Sentry from "@sentry/node";
const dsn = process.env.SENTRY_PUBLIC_DSN || process.env.SENTRY_DSN

if (dsn) {
  console.log("sentry dsn: ", dsn);
  Sentry.init({ dsn, environment: process.env.RAILS_ENV });
}

import { Server } from "@hocuspocus/server";

// trying make things backwards compatible for people doing ./update.sh
// hocuspocus calling back to rails server to auth the connecting browser
const authUrl = (process.env.PRIVATE_APP_URL ||
                 process.env.APP_URL ||
                 process.env.PUBLIC_APP_URL ||
                `https://${process.env.CANONICAL_HOST}`) + '/api/hocuspocus'

const port = (process.env.RAILS_ENV == 'production') ? 80 : parseInt(process.env.HOCUSPOCUS_PORT || '4444')

console.info("hocuspocus auth authUrl: ", authUrl);

function log(event, data = {}) {
  console.log(JSON.stringify({ event, ...data, ts: new Date().toISOString() }));
  Sentry.addBreadcrumb({ message: event, data, level: 'info', category: 'hocuspocus' });
}

const server = new Server({
  port: port,
  timeout: 30000,
  debounce: 5000,
  maxDebounce: 30000,
  quiet: true,
  name: "hocuspocus",
  async onConnect(data) {
    log('connect', { documentName: data.documentName });
  },
  async onAuthenticate(data) {
    const { token, documentName } = data;
    let response;
    try {
      response = await fetch(authUrl, {
          method: 'POST',
          body: JSON.stringify({ user_secret: token, document_name: documentName }),
          headers: { 'Content-type': 'application/json; charset=UTF-8' },
      });
    } catch (e) {
      Sentry.withScope(scope => {
        scope.setContext('hocuspocus', { documentName });
        Sentry.captureException(e);
      });
      throw e;
    }

    if (response.status != 200) {
      log('auth.rejected', { documentName, status: response.status });
      throw new Error("Not authorized!");
    }
    return true;
  },
  async onLoadDocument(data) {
    log('load_document', { documentName: data.documentName });
  },
  async onStoreDocument(data) {
    log('store_document', { documentName: data.documentName });
  },
  async onDisconnect(data) {
    log('disconnect', { documentName: data.documentName });
  },
});

server.listen().catch(e => {
  Sentry.captureException(e);
  process.exit(1);
});
