//= require ahoy

ahoy.configure({
  // urlPrefix: "",
  visitsUrl: "/bhoy/visits",
  eventsUrl: "/bhoy/events",
  // page: null,
  // platform: "Web",
  // useBeacon: true,
  // startOnReady: true,
  // trackVisits: true,
  // cookies: true,
  cookieDomain: "loomio.org",
  // headers: {},
  // visitParams: {},
  // withCredentials: false,
  // visitDuration: 4 * 60, // 4 hours
  // visitorDuration: 2 * 365 * 24 * 60 // 2 years
})

ahoy.trackAll()
