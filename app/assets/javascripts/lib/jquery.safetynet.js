/**
 * jQuery.safetynet
 * A smarter in-browser "unsaved changes" warning
 *
 * version 0.9.4
 *
 * http://michaelmonteleone.net/projects/safetynet
 * http://github.com/mmonteleone/jquery.safetynet
 *
 * Copyright (c) 2009 Michael Monteleone
 * Licensed under terms of the MIT License (README.markdown)
 */
(function($){

    var changeFlags = {},       // Stores a listing of raised changes by their key
        suppressed = false,     // whether or not warning should be suppressed
        uniqueIdentifiers = 0,  // accumulator for providing page-unique ids for anonymous elements
        activated = false,      // whether or not the plugin has already been activated for a given page
        idDataKey = 'safetynet-identifier',  // key to use internally for storing ids on .data()
        selection,
        events,
        currentJqSupportsLive = Number($.fn.jquery.split('.').slice(0,2).join('.')) >= 1.4;

    /**
     * Helper which returns whether an object is null
     * or in the case that it's a string or array, if it's empty
     * @param {Object} obj Object to check (could be string too)
     * @returns {Boolean} whether or not item is null or empty
     */
    var isNullOrEmpty = function(obj) {
        return obj === null ||
            (typeof obj.length !== "undefined" && obj.length === 0);
    };

    /**
     * Helper which returns a unique identifier for a given input
     * Yes, ieally an input should have a name,
     * but this saves the day even when they don't
     * @param {jQuery} selection selection of an input
     * @returns {string} key
     */
    var fieldIdentifierFor = function(sel) {
        sel = $(sel);

        // if field has a name, use that
        var name = sel.attr('name');
        if(typeof name !== "undefined" && !isNullOrEmpty(name)) {
            return name;
        }

        // otherwise, if has an id, use that
        var id = sel.attr('id');
        if(typeof id !== "undefined" && !isNullOrEmpty(id)) {
            return id;
        }

        // finally, if neither, just make up a new unique
        // key for it and store it for later
        var uid = sel.data(idDataKey);
        if(typeof uid === "undefined" || uid === null) {
            uid = uniqueIdentifiers++;
            sel.data(idDataKey, uid);
        }
        return uid;
    };

    /**
     * Helper which returns the number of properties
     * on an object.  Used to know how many changes are
     * currently cached in the changeFlags object
     * @param {object} obj Any object
     * @returns {Number} the number of properties on the object
     */
    var countProperties = function(obj) {
        // helpful modern browsers can alreay do this.
        if(typeof obj.__count__ !== "undefined") {
            return obj.__count__;
        } else {
            // and others can't.
            var count = 0;
            for (var k in obj) {
                if (obj.hasOwnProperty(k)) {
                    count++;
                }
            }
            return count;
        }
    };

    /**
     * SafetyNet plugin.  Registers the matched selectors for tracking changes
     * in order to logically display a warning prompt when leaving an un-submitted form.
     * @param {Object} options optional object literal of plugin options
     */
    $.fn.safetynet = function(options){
        var settings = $.extend({}, $.safetynet.defaults, options || {});
        var binder = settings.live ? 'live' : 'bind';

        selection = this;
        events = settings.netChangerEvents;

        if(activated) {
            throw('Only one activation of jQuery.safetynet is allowed per page');
        }
        activated = true;

        // throw an exception if netchanger wasn't loadeds
        if(typeof $.fn.netchanger === "undefined") {
            throw('jQuery.safetynet requires a missing dependency, jQuery.netchanger.');
        }

        // throw exception if live set but no jq 1.4 or greater
        if(!currentJqSupportsLive && settings.live) {
            throw("Use of the live option requires jQuery 1.4 or greater");
        }

        // set up selected inputs to raise netchanger events
        this.netchanger({events: events, live: settings.live})
            // register an input's change on 'netchange'
            [binder]('netchange', function(e){
                $.safetynet.raiseChange(fieldIdentifierFor(this), e.target);
                })
            // clear an input's change on 'revertchange's
            [binder]('revertchange', function(){
                $.safetynet.clearChange(fieldIdentifierFor(this));
                });

        // hook onto the onbeforeunload
        // this is a strange pseudo-event that can't be jQuery.fn.bind()'ed to
        window.onbeforeunload = function() {
            // when suppressed, don't do anything but clear the suppression
            if($.safetynet.suppressed()) {
                $.safetynet.suppressed(false);
                return undefined;
            }
            // show the popup only if there's changes
            // returning null from an onbeforeunload is the (strange) way of making it do nothing
            return $.safetynet.hasChanges() ? settings.message : undefined;
        };
        // set form submissions to suppress warnings
        $(settings.form)[binder]('submit', function(){ $.safetynet.suppressed(true); });

        return this;
    };

    /**
     * Shortcut alias for $($.safetynet.defaults.fields).safetynet(options);
     * @param {Object} options
     */
    $.safetynet = function(options){
        $($.safetynet.defaults.fields).safetynet(options);
    };

    $.extend($.safetynet,{
        reBind: function() {
            // set up selected inputs to raise netchanger events
            selection.netchanger({events: events});
        },
        /**
         * Manually registers a change with Safetynet, so that a warning is
         * prompted when the user navigates away.  This can be useful for custom
         * widgets like drag-and-drop to register their changed states.
         * @param {String} key a key is required since changes are tracked per-control
         *  in order to be able to cancel changes per-control. Key can be literal
         *  string to associate change with, or a jQuery object to traverse and associate
         *  changes with each matched element
         * @param {Object} value optional value to assign to the key being raised
         */
        raiseChange: function(key, value) {
            if(typeof key === "undefined" || isNullOrEmpty(key)) {
                throw("key is required when raising a jQuery.safetynet change");
            } else if(key instanceof $) {
                key.each(function(){
                    changeFlags[fieldIdentifierFor($(this))] = true;
                });
            } else {
                changeFlags[key] = value || true;
            }
        },
        /**
         * Manually un-registers a change with Safetynet.
         * As with automatically raised/cleared changes, if this is the last change to clear,
         * the warning prompt will no longer be set to display on next page navigation.
         * @param {String} key A key is required since changes are tracked per-control.
         * Key can be literal string to associate change with, or a jQuery object to traverse and associate
         * changes with each matched element
         */
        clearChange: function(key) {
            if(typeof key === "undefined" || isNullOrEmpty(key)) {
                throw("key is required when clearing a jQuery.safetynet change");
            } else if(key instanceof $) {
                key.each(function(){
                    delete changeFlags[fieldIdentifierFor($(this))]
                });
            } else {
                delete changeFlags[key];
            }
        },
        /**
         * Manually un-registers all raised changes.
         * Warning prompt will not display on next page navigation.
         */
        clearAllChanges: function(key) {
            changeFlags = {};
            activated = false;
        },
        /**
         * Returns and/or sets the suppressed state.
         * Allows for manually suppressing the save warning, even if there are raised changes.
         * @param {Boolean} val optional value to set for the suppressed state
         */
        suppressed: function(val) {
            if(arguments.length === 1) {
                suppressed = val;
            }
            return suppressed;
        },
        /**
         * Returns whether there are currently-registered changes.
         */
        hasChanges: function() {
            // earlier versions of jQuery did not support 'contain'
            if('contains' in $) {
                // when 'contain' does exist, use it to help verify
                // that not only are changes raised, but if the changes
                // are related to specific inputs, that the inputs themselves still
                // exist
                var applicableChanges = {};
                $.each(changeFlags, function(key, value) {
                    if(typeof value === "boolean" || $.contains(document.body, value)) {
                        applicableChanges[key] = value;
                    }
                });
                return countProperties(applicableChanges) > 0;
            } else {
                return countProperties(changeFlags) > 0;                
            }
        },
        version: '0.9.5',
        defaults: {
            // The message to show the user when navigating away from a non-submitted form
            message: 'Your unsaved changes will be lost.',
            // Selector of default fields to monitor when using the `$.safetynet()` shortcut alias
            fields: 'input,select,textarea,fileupload',
            // Selector of forms on which to bind their `submit` event to suppress prompting
            form: 'form',
            // events on which to check for changes to the control
            netChangerEvents: 'change,keyup,paste',
            // defaults to live handling when in jq 1.4
            live: currentJqSupportsLive
        }
    });
})(jQuery);