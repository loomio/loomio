/*jshint bitwise: false*/

(function (root, factory) {
  if (typeof define === 'function' && define.amd) {
    // AMD. Register as an anonymous module.
    define([], function (b) {
      // Also create a global in case some scripts
      // that are loaded still are looking for
      // a global even when an AMD loader is in use.
      return (root.MessageBus = factory());
    });
  } else {
    // Browser globals
    root.MessageBus = factory();
  }
}(typeof self !== 'undefined' ? self : this, function () {
  "use strict";

  // http://stackoverflow.com/questions/105034/how-to-create-a-guid-uuid-in-javascript
  var uniqueId = function() {
    return "xxxxxxxxxxxx4xxxyxxxxxxxxxxxxxxx".replace(/[xy]/g, function(c) {
      var r = (Math.random() * 16) | 0;
      var v = c === "x" ? r : (r & 0x3) | 0x8;
      return v.toString(16);
    });
  };

  var me;
  var delayPollTimeout;
  var ajaxInProgress = false;
  var started = false;
  var clientId = uniqueId();
  var callbacks = [];
  var queue = [];
  var interval = null;
  var failCount = 0;
  var baseUrl = "/";
  var paused = false;
  var later = [];
  var chunkedBackoff = 0;
  var stopped;
  var pollTimeout = null;
  var totalAjaxFailures = 0;
  var totalAjaxCalls = 0;
  var lastAjax;

  var isHidden = (function() {
    var prefixes = ["", "webkit", "ms", "moz"];
    var hiddenProperty;
    for (var i = 0; i < prefixes.length; i++) {
      var prefix = prefixes[i];
      var check = prefix + (prefix === "" ? "hidden" : "Hidden");
      if (document[check] !== undefined) {
        hiddenProperty = check;
      }
    }

    return function() {
      if (hiddenProperty !== undefined) {
        return document[hiddenProperty];
      } else {
        return !document.hasFocus;
      }
    };
  })();

  var hasLocalStorage = (function() {
    try {
      localStorage.setItem("mbTestLocalStorage", Date.now());
      localStorage.removeItem("mbTestLocalStorage");
      return true;
    } catch (e) {
      return false;
    }
  })();

  var updateLastAjax = function() {
    if (hasLocalStorage) {
      localStorage.setItem("__mbLastAjax", Date.now());
    }
  };

  var hiddenTabShouldWait = function() {
    if (hasLocalStorage && isHidden()) {
      var lastAjaxCall = parseInt(localStorage.getItem("__mbLastAjax"), 10);
      var deltaAjax = Date.now() - lastAjaxCall;

      return deltaAjax >= 0 && deltaAjax < me.minHiddenPollInterval;
    }
    return false;
  };

  var hasonprogress = new XMLHttpRequest().onprogress === null;
  var allowChunked = function() {
    return me.enableChunkedEncoding && hasonprogress;
  };

  var shouldLongPoll = function() {
    return (
      me.alwaysLongPoll ||
      (me.shouldLongPollCallback ? me.shouldLongPollCallback() : !isHidden())
    );
  };

  var processMessages = function(messages) {
    var gotData = false;
    if ((!messages) || (messages.length === 0)) { return false; }

    for (var i = 0; i < messages.length; i++) {
      var message = messages[i];
      for (var j = 0; j < callbacks.length; j++) {
        var callback = callbacks[j];
        if (callback.channel === message.channel) {
          callback.last_id = message.message_id;
          try {
            callback.func(message.data, message.global_id, message.message_id);
          } catch (e) {
            if (console.log) {
              console.log(
                "MESSAGE BUS FAIL: callback " +
                  callback.channel +
                  " caused exception " +
                  e.stack
              );
            }
          }
        }
        if (message.channel === "/__status") {
          if (message.data[callback.channel] !== undefined) {
            callback.last_id = message.data[callback.channel];
          }
        }
      }
    }

    return true;
  };

  var reqSuccess = function(messages) {
    failCount = 0;
    if (paused) {
      if (messages) {
        for (var i = 0; i < messages.length; i++) {
          later.push(messages[i]);
        }
      }
    } else {
      return processMessages(messages);
    }
    return false;
  };

  var longPoller = function(poll, data) {
    if (ajaxInProgress) {
      // never allow concurrent ajax reqs
      return;
    }

    var gotData = false;
    var aborted = false;
    var rateLimited = false;
    var rateLimitedSeconds;

    lastAjax = new Date();
    totalAjaxCalls += 1;
    data.__seq = totalAjaxCalls;

    var longPoll = shouldLongPoll() && me.enableLongPolling;
    var chunked = longPoll && allowChunked();
    if (chunkedBackoff > 0) {
      chunkedBackoff--;
      chunked = false;
    }

    var headers = { "X-SILENCE-LOGGER": "true" };
    for (var name in me.headers) {
      headers[name] = me.headers[name];
    }

    if (!chunked) {
      headers["Dont-Chunk"] = "true";
    }

    var dataType = chunked ? "text" : "json";

    var handle_progress = function(payload, position) {
      var separator = "\r\n|\r\n";
      var endChunk = payload.indexOf(separator, position);

      if (endChunk === -1) {
        return position;
      }

      var chunk = payload.substring(position, endChunk);
      chunk = chunk.replace(/\r\n\|\|\r\n/g, separator);

      try {
        reqSuccess(JSON.parse(chunk));
      } catch (e) {
        if (console.log) {
          console.log("FAILED TO PARSE CHUNKED REPLY");
          console.log(data);
        }
      }

      return handle_progress(payload, endChunk + separator.length);
    };

    var disableChunked = function() {
      if (me.longPoll) {
        me.longPoll.abort();
        chunkedBackoff = 30;
      }
    };

    var setOnProgressListener = function(xhr) {
      var position = 0;
      // if it takes longer than 3000 ms to get first chunk, we have some proxy
      // this is messing with us, so just backoff from using chunked for now
      var chunkedTimeout = setTimeout(disableChunked, 3000);
      xhr.onprogress = function() {
        clearTimeout(chunkedTimeout);
        if (
          xhr.getResponseHeader("Content-Type") ===
          "application/json; charset=utf-8"
        ) {
          // not chunked we are sending json back
          chunked = false;
          return;
        }
        position = handle_progress(xhr.responseText, position);
      };
    };
    if (!me.ajax) {
      throw new Error("Either jQuery or the ajax adapter must be loaded");
    }

    updateLastAjax();

    ajaxInProgress = true;
    var req = me.ajax({
      url:
        me.baseUrl +
        "message-bus/" +
        me.clientId +
        "/poll" +
        (!longPoll ? "?dlp=t" : ""),
      data: data,
      cache: false,
      async: true,
      dataType: dataType,
      type: "POST",
      headers: headers,
      messageBus: {
        chunked: chunked,
        onProgressListener: function(xhr) {
          var position = 0;
          // if it takes longer than 3000 ms to get first chunk, we have some proxy
          // this is messing with us, so just backoff from using chunked for now
          var chunkedTimeout = setTimeout(disableChunked, 3000);
          return (xhr.onprogress = function() {
            clearTimeout(chunkedTimeout);
            if (
              xhr.getResponseHeader("Content-Type") ===
              "application/json; charset=utf-8"
            ) {
              chunked = false; // not chunked, we are sending json back
            } else {
              position = handle_progress(xhr.responseText, position);
            }
          });
        }
      },
      xhr: function() {
        var xhr = jQuery.ajaxSettings.xhr();
        if (!chunked) {
          return xhr;
        }
        this.messageBus.onProgressListener(xhr);
        return xhr;
      },
      success: function(messages) {
        if (!chunked) {
          // we may have requested text so jQuery will not parse
          if (typeof messages === "string") {
            messages = JSON.parse(messages);
          }
          gotData = reqSuccess(messages);
        }
      },
      error: function(xhr, textStatus, err) {
        if (xhr.status === 429) {
          var tryAfter =
            parseInt(
              xhr.getResponseHeader && xhr.getResponseHeader("Retry-After")
            ) || 0;
          tryAfter = tryAfter || 0;
          if (tryAfter < 15) {
            tryAfter = 15;
          }
          rateLimitedSeconds = tryAfter;
          rateLimited = true;
        } else if (textStatus === "abort") {
          aborted = true;
        } else {
          failCount += 1;
          totalAjaxFailures += 1;
        }
      },
      complete: function() {
        ajaxInProgress = false;

        var interval;
        try {
          if (rateLimited) {
            interval = Math.max(me.minPollInterval, rateLimitedSeconds * 1000);
          } else if (gotData || aborted) {
            interval = me.minPollInterval;
          } else {
            interval = me.callbackInterval;
            if (failCount > 2) {
              interval = interval * failCount;
            } else if (!shouldLongPoll()) {
              interval = me.backgroundCallbackInterval;
            }
            if (interval > me.maxPollInterval) {
              interval = me.maxPollInterval;
            }

            interval -= new Date() - lastAjax;

            if (interval < 100) {
              interval = 100;
            }
          }
        } catch (e) {
          if (console.log && e.message) {
            console.log("MESSAGE BUS FAIL: " + e.message);
          }
        }

        if (pollTimeout) {
          clearTimeout(pollTimeout);
          pollTimeout = null;
        }

        if (started) {
          pollTimeout = setTimeout(function() {
            pollTimeout = null;
            poll();
          }, interval);
        }

        me.longPoll = null;
      }
    });

    return req;
  };

  me = {
    /* shared between all tabs */
    minHiddenPollInterval: 1500,
    enableChunkedEncoding: true,
    enableLongPolling: true,
    callbackInterval: 15000,
    backgroundCallbackInterval: 60000,
    minPollInterval: 100,
    maxPollInterval: 3 * 60 * 1000,
    callbacks: callbacks,
    clientId: clientId,
    alwaysLongPoll: false,
    shouldLongPollCallback: undefined,
    baseUrl: baseUrl,
    headers: {},
    ajax: typeof jQuery !== "undefined" && jQuery.ajax,
    diagnostics: function() {
      console.log("Stopped: " + stopped + " Started: " + started);
      console.log("Current callbacks");
      console.log(callbacks);
      console.log(
        "Total ajax calls: " +
          totalAjaxCalls +
          " Recent failure count: " +
          failCount +
          " Total failures: " +
          totalAjaxFailures
      );
      console.log(
        "Last ajax call: " + (new Date() - lastAjax) / 1000 + " seconds ago"
      );
    },

    pause: function() {
      paused = true;
    },

    resume: function() {
      paused = false;
      processMessages(later);
      later = [];
    },

    stop: function() {
      stopped = true;
      started = false;
      if (delayPollTimeout) {
        clearTimeout(delayPollTimeout);
        delayPollTimeout = null;
      }
      if (me.longPoll) {
        me.longPoll.abort();
      }
    },

    // Start polling
    start: function() {
      if (started) return;
      started = true;
      stopped = false;

      var poll = function() {
        if (stopped) {
          return;
        }

        if (callbacks.length === 0 || hiddenTabShouldWait()) {
          if (!delayPollTimeout) {
            delayPollTimeout = setTimeout(function() {
              delayPollTimeout = null;
              poll();
            }, parseInt(500 + Math.random() * 500));
          }
          return;
        }

        var data = {};
        for (var i = 0; i < callbacks.length; i++) {
          data[callbacks[i].channel] = callbacks[i].last_id;
        }

        // could possibly already be started
        // notice the delay timeout above
        if (!me.longPoll) {
          me.longPoll = longPoller(poll, data);
        }
      };

      // monitor visibility, issue a new long poll when the page shows
      if (document.addEventListener && "hidden" in document) {
        me.visibilityEvent = document.addEventListener(
          "visibilitychange",
          function() {
            if (!document.hidden && !me.longPoll && pollTimeout) {
              clearTimeout(pollTimeout);
              clearTimeout(delayPollTimeout);

              delayPollTimeout = null;
              pollTimeout = null;
              poll();
            }
          }
        );
      }

      poll();
    },

    status: function() {
      if (paused) {
        return "paused";
      } else if (started) {
        return "started";
      } else if (stopped) {
        return "stopped";
      } else {
        throw "Cannot determine current status";
      }
    },

    // Subscribe to a channel
    // if lastId is 0 or larger, it will recieve messages AFTER that id
    // if lastId is negative it will perform lookbehind
    // -1 will subscribe to all new messages
    // -2 will recieve last message + all new messages
    // -3 will recieve last 2 messages + all new messages
    subscribe: function(channel, func, lastId) {
      if (!started && !stopped) {
        me.start();
      }

      if (typeof lastId !== "number") {
        lastId = -1;
      }

      if (typeof channel !== "string") {
        throw "Channel name must be a string!";
      }

      callbacks.push({
        channel: channel,
        func: func,
        last_id: lastId
      });
      if (me.longPoll) {
        me.longPoll.abort();
      }

      return func;
    },

    // Unsubscribe from a channel
    unsubscribe: function(channel, func) {
      // TODO allow for globbing in the middle of a channel name
      // like /something/*/something
      // at the moment we only support globbing /something/*
      var glob = false;
      if (channel.indexOf("*", channel.length - 1) !== -1) {
        channel = channel.substr(0, channel.length - 1);
        glob = true;
      }

      var removed = false;

      for (var i = callbacks.length - 1; i >= 0; i--) {
        var callback = callbacks[i];
        var keep;

        if (glob) {
          keep = callback.channel.substr(0, channel.length) !== channel;
        } else {
          keep = callback.channel !== channel;
        }

        if (!keep && func && callback.func !== func) {
          keep = true;
        }

        if (!keep) {
          callbacks.splice(i, 1);
          removed = true;
        }
      }

      if (removed && me.longPoll) {
        me.longPoll.abort();
      }

      return removed;
    }
  };
  return me;
}));
