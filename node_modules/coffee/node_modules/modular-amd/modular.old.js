/*
 * Modular - JavaScript AMD Framework
 * Copyright 2013 Dan Phillimore (asmblah)
 * http://asmblah.github.com/modular/
 *
 * Implements the AMD specification - see https://github.com/amdjs/amdjs-api/wiki/AMD
 *
 * Released under the MIT license
 * https://github.com/asmblah/modular/raw/master/MIT-LICENSE.txt
 */

(function () {
    "use strict";
    /*global require, module */

    var global = new [Function][0]("return this;")(), // Keep JSLint happy
        has = {}.hasOwnProperty,
        slice = [].slice,
        get = function (obj, prop) {
            return obj[prop];
        },
        undef = undefined, // Closure compiler seems happier with this, compresses smaller
        util = {
            each: function (obj, callback, options) {
                var key,
                    length;

                if (!obj) {
                    return;
                }

                options = options || {};

                if (has.call(obj, "length") && !options.keys) {
                    for (key = 0, length = obj.length; key < length; key += 1) { // Keep JSLint happy with "+= 1"
                        if (callback.call(obj[key], obj[key], key) === false) {
                            break;
                        }
                    }
                } else {
                    for (key in obj) {
                        if (has.call(obj, key)) {
                            if (callback.call(obj[key], obj[key], key) === false) {
                                break;
                            }
                        }
                    }
                }
            },

            extend: function (target) {
                util.each(slice.call(arguments, 1), function (obj) {
                    util.each(obj, function (val, key) {
                        target[key] = val;
                    }, { keys: true });
                });

                return target;
            },

            getType: function (obj) {
                return {}.toString.call(obj).match(/\[object ([\s\S]*)\]/)[1];
            },

            global: global,

            isArray: function (str) {
                return util.getType(str) === "Array";
            },

            isFunction: function (str) {
                return util.getType(str) === "Function";
            },

            isPlainObject: function (obj) {
                return util.getType(obj) === "Object" && !util.isUndefined(obj);
            },

            isString: function (str) {
                return typeof str === "string" || util.getType(str) === "String";
            },

            isUndefined: function (obj) {
                return obj === undef;
            }
        },
        Funnel = (function () {
            function Funnel() {
                this.doneCallbacks = [];
                this.pending = 0;
            }
            util.extend(Funnel.prototype, {
                add: function (callback) {
                    var funnel = this;

                    funnel.pending += 1;

                    return function () {
                        var result = callback.apply(this, arguments);

                        funnel.pending -= 1;
                        if (funnel.pending === 0) {
                            util.each(funnel.doneCallbacks, function (callback) {
                                callback();
                            });
                        }

                        return result;
                    };
                },

                done: function (callback) {
                    if (this.pending === 0) {
                        callback();
                    } else {
                        this.doneCallbacks.push(callback);
                    }
                }
            });

            return Funnel;
        }()),
        Module = (function () {
            var UNDEFINED = 1,
                TRANSPORTING = 2,
                FILTERING = 3,
                DEFINED = 4,
                DEFERRED = 5,
                LOADING = 6,
                LOADED = 7;

            function Module(loader, config, id, value) {
                var module = this;
                this.config = util.extend({}, config);
                this.dependencies = [];
                this.factory = null;
                this.id = id || null;
                this.loader = loader;
                this.mode = value ? LOADED : UNDEFINED;
                this.requesterQueue = [];
                this.whenLoaded = null;
                this.commonJSModule = {
                    defer: function () {
                        module.mode = DEFERRED;
                        return function (value) {
                            module.whenLoaded(value);
                        };
                    },
                    exports: value
                };
            }
            util.extend(Module.prototype, {
                define: function (config, dependencyIDs, factory, callback) {
                    var loader = this.loader,
                        module = this,
                        idFilter,
                        funnel = new Funnel();

                    util.extend(module.config, config);
                    idFilter = get(module.config, "idFilter");

                    util.extend(module.commonJSModule, {
                        config: module.config,
                        id: module.id,
                        uri: module.id
                    });

                    util.each(dependencyIDs, function (dependencyID, dependencyIndex) {
                        dependencyID = loader.resolveDependencyID(dependencyID, module.id, get(module.config, "paths"), get(module.config, "exclude"));

                        if (dependencyID === "require") {
                            module.dependencies[dependencyIndex] = new Module(loader, module.config, null, function (arg1, arg2, arg3, arg4) {
                                var args = loader.parseArgs(arg1, arg2, arg3, arg4),
                                    config = util.extend({}, module.config, args.config);
                                return loader.require(config, args.id || module.id, args.dependencyIDs, args.factory);
                            });
                        } else if (dependencyID === "exports") {
                            if (util.isUndefined(module.commonJSModule.exports)) {
                                module.commonJSModule.exports = {};
                            }
                            module.dependencies[dependencyIndex] = new Module(loader, module.config, null, module.commonJSModule.exports);
                        } else if (dependencyID === "module") {
                            if (util.isUndefined(module.commonJSModule.exports)) {
                                module.commonJSModule.exports = {};
                            }
                            module.dependencies[dependencyIndex] = new Module(loader, module.config, null, module.commonJSModule);
                        } else {
                            idFilter(dependencyID, funnel.add(function (dependencyID) {
                                var dependency = loader.getModule(dependencyID);

                                if (dependency) {
                                    util.extend(dependency.config, module.config);
                                } else {
                                    dependency = loader.createModule(dependencyID, module.config);
                                }

                                module.dependencies[dependencyIndex] = dependency;
                            }));
                        }
                    });

                    module.factory = factory;

                    module.mode = FILTERING;

                    funnel.done(function () {
                        module.mode = DEFINED;
                        if (callback) {
                            callback();
                        }
                    });
                },

                getDependencies: function () {
                    return this.dependencies;
                },

                getID: function () {
                    return this.id;
                },

                getValue: function () {
                    var module = this;

                    return module.commonJSModule.exports;
                },

                isDeferred: function () {
                    return this.mode === DEFERRED;
                },

                isDefined: function () {
                    return this.mode >= FILTERING;
                },

                isLoaded: function () {
                    return this.mode === LOADED;
                },

                load: function (callback) {
                    var loader = this.loader,
                        module = this;

                    function load(dependencyValues, value, callback) {
                        module.mode = LOADED;

                        if (!util.isUndefined(value)) {
                            module.commonJSModule.exports = value;
                        }

                        util.each(module.requesterQueue, function (callback) {
                            callback(module.getValue());
                        });
                        module.requesterQueue.length = 0;

                        if (callback) {
                            callback(module.getValue());
                        }
                    }

                    function getModuleValue(dependencyValues, factory, callback) {
                        var value;

                        module.whenLoaded = function (value) {
                            module.whenLoaded = null;
                            load(dependencyValues, value, callback);
                        };

                        value = util.isFunction(factory) ?
                                factory.apply(global, dependencyValues) :
                                factory;

                        if (!module.isDeferred() && !module.isLoaded()) {
                            module.whenLoaded = null;
                            load(dependencyValues, value, callback);
                        }
                    }

                    function filter(dependencyValues, callback) {
                        var factoryFilter = get(module.config, "factoryFilter");

                        factoryFilter({
                            callback: function (factory) {
                                getModuleValue(dependencyValues, factory, callback);
                            },
                            dependencyValues: dependencyValues,
                            factory: module.factory,
                            id: module.getID(),
                            loader: loader
                        });
                    }

                    function loadDependencies(callback) {
                        var funnel = new Funnel(),
                            dependencyValues = [];

                        module.mode = LOADING;

                        util.each(module.dependencies, function (dependency, index) {
                            dependency.load(funnel.add(function (value) {
                                // These may load in any order, so don't just .push() them
                                dependencyValues[index] = value;
                            }));
                        });

                        funnel.done(function () {
                            filter(dependencyValues, callback);
                        });
                    }

                    function completeDefine(define) {
                        if (!define) {
                            define = {
                                config: {},
                                dependencyIDs: [],
                                factory: undef
                            };
                        }

                        module.define(define.config, define.dependencyIDs, define.factory, function () {
                            loadDependencies();
                        });
                    }

                    if (module.mode === UNDEFINED) {
                        if (callback) {
                            module.requesterQueue.push(callback);
                        }
                        module.mode = TRANSPORTING;

                        get(module.config, "transport")(completeDefine, module);
                    } else if (module.mode === TRANSPORTING || module.mode === LOADING) {
                        if (callback) {
                            module.requesterQueue.push(callback);
                        }
                    } else if (module.mode === DEFINED) {
                        loadDependencies(callback);
                    } else if (module.mode === LOADED) {
                        if (callback) {
                            callback(module.getValue());
                        }
                    }
                }
            });

            return Module;
        }()),
        Modular = (function () {
            function Modular() {
                this.config = {
                    "baseUrl": "",
                    "defineAnonymous": function (args) {},
                    "exclude": /(?!)/,
                    "factoryFilter": function (args) {
                        args.callback(args.factory);
                    },
                    "idFilter": function (id, callback) {
                        callback(id);
                    },
                    "transport": function (callback, module) {}
                };
                this.modules = {};

                // Expose Modular class itself to dependents
                this.define("Modular", function () {
                    return Modular;
                });

                // Expose this instance of Modular to its dependents
                this.define("modular", this);
            }
            util.extend(Modular.prototype, {
                configure: function (config) {
                    if (config) {
                        util.extend(this.config, config);
                    } else {
                        return this.config;
                    }
                },

                createDefiner: function () {
                    var loader = this;

                    function define(arg1, arg2, arg3, arg4) {
                        return loader.define(arg1, arg2, arg3, arg4);
                    }

                    // Publish support for the AMD pattern
                    util.extend(define, {
                        "amd": {
                            "jQuery": true
                        }
                    });

                    return define;
                },

                createModule: function (id, config) {
                    var module = new Module(this, config, id);

                    this.modules[id] = module;

                    return module;
                },

                createRequirer: function () {
                    var loader = this;

                    function require(arg1, arg2, arg3, arg4) {
                        return loader.require(arg1, arg2, arg3, arg4);
                    }

                    util.extend(require, {
                        config: function (config) {
                            return loader.configure(config);
                        }
                    });

                    return require;
                },

                define: function (arg1, arg2, arg3, arg4) {
                    var args = this.parseArgs(arg1, arg2, arg3, arg4),
                        id = args.id,
                        module;

                    if (id === null) {
                        get(util.extend({}, this.config, args.config), "defineAnonymous")(args);
                    } else {
                        module = this.getModule(id);
                        if (module) {
                            if (module.isDefined()) {
                                throw new Error("Module '" + id + "' has already been defined");
                            }
                        } else {
                            module = this.createModule(id, util.extend({}, this.config, args.config));
                        }

                        module.define(args.config, args.dependencyIDs, args.factory);
                    }
                },

                getModule: function (id) {
                    return this.modules[id];
                },

                parseArgs: function (arg1, arg2, arg3, arg4) {
                    var config = null,
                        id = null,
                        dependencyIDs = null,
                        factory = undef;

                    if (util.isPlainObject(arg1)) {
                        config = arg1;
                    } else if (util.isString(arg1)) {
                        id = arg1;
                    } else if (util.isArray(arg1)) {
                        dependencyIDs = arg1;
                    } else if (util.isFunction(arg1)) {
                        factory = arg1;
                    }

                    if (util.isString(arg2)) {
                        id = arg2;
                    } else if (util.isArray(arg2)) {
                        dependencyIDs = arg2;
                    } else if (util.isFunction(arg2) || util.isPlainObject(arg2)) {
                        factory = arg2;
                    }

                    if (util.isArray(arg3)) {
                        dependencyIDs = arg3;
                    } else if (util.isFunction(arg3) || util.isPlainObject(arg3)) {
                        factory = arg3;
                    }

                    if (util.isFunction(arg4)) {
                        factory = arg4;
                    }

                    // Special case: only an object passed - use as factory
                    if (config && !id && !dependencyIDs && !factory) {
                        factory = config;
                        config = null;
                    }

                    // Special case: only an array passed - use as factory
                    if (!config && dependencyIDs && !id && !factory) {
                        factory = dependencyIDs;
                        dependencyIDs = null;
                    }

                    return {
                        config: config || {},
                        id: id,
                        dependencyIDs: dependencyIDs || [],
                        factory: factory
                    };
                },

                resolveDependencyID: function (id, dependentID, mappings, exclude) {
                    var previousID;

                    if (!util.isString(id)) {
                        throw new Error("Invalid dependency id");
                    }

                    if (exclude && exclude.test(id)) {
                        return id;
                    }

                    if (/^\.\.?\//.test(id) && dependentID) {
                        id = dependentID.replace(/[^\/]+$/, "") + id;
                        mappings = null;
                    }

                    // Resolve parent-directory terms
                    while (previousID !== id) {
                        previousID = id;
                        id = id.replace(/(^|\/)(?!\.\.)([^\/]*)\/\.\.\//, "$1");
                    }

                    if (mappings && !/^\.\.?\//.test(id)) {
                        id = (function () {
                            var terms = id.split("/"),
                                portion,
                                index;

                            if (mappings[id]) {
                                return mappings[id];
                            }

                            for (index = terms.length - 1; index >= 0; index -= 1) {
                                portion = terms.slice(0, index).join("/");
                                if (mappings[portion] || mappings[portion + "/"]) {
                                    return (mappings[portion] || mappings[portion + "/"]).replace(/\/$/, "") + "/" + terms.slice(index).join("/");
                                }
                            }
                            return id;
                        }());
                    }

                    id = id.replace(/(^|\/)(\.?\/)+/g, "$1").replace(/^\//, ""); // Resolve same-directory terms

                    return id;
                },

                require: function (arg1, arg2, arg3, arg4) {
                    var args = this.parseArgs(arg1, arg2, arg3, arg4),
                        id = args.id,
                        module;

                    if (args.id && args.dependencyIDs.length === 0 && !args.factory) {
                        module = this.getModule(args.id);

                        if (!module || (!module.isLoaded() && module.getDependencies().length > 0)) {
                            throw new Error("Module '" + args.id + "' has not yet loaded");
                        }

                        module.load();

                        return module.getValue();
                    } else {
                        module = new Module(this, this.config, id);

                        module.define(args.config, args.dependencyIDs, args.factory, function () {
                            module.load();
                        });
                    }
                },

                util: util
            });

            return Modular;
        }()),
        modular = new Modular();

    (function () {
        var isNode = (typeof require !== "undefined" && typeof module !== "undefined");

        function makePath(baseURI, id) {
            if (/\?/.test(id)) {
                return id;
            }

            if (!/^(https?:)?\/\//.test(id)) {
                id = (baseURI ? baseURI.replace(/\/$/, "") + "/" : "") + id;
            }

            return id.replace(/\.js$/, "") + ".js";
        }

        // Don't override an existing AMD loader: instead, register the Modular instance
        if (global.define) {
            global.define(modular);
        } else {
            global.define = modular.createDefiner();

            if (isNode) {
                module.exports = modular;

                (function (nodeRequire) {
                    var anonymousDefine,
                        fs = nodeRequire("fs"),
                        // Expose Modular require() to loaded script
                        require = modular.createRequirer();

                    modular.configure({
                        "defineAnonymous": function (args) {
                            anonymousDefine = args;
                        },
                        "exec": function (args) {
                            /*jslint evil:true */
                            eval(args.code);
                            args.callback();
                        },
                        "transport": function (callback, module) {
                            var path = fs.realpathSync(makePath(get(module.config, "baseUrl"), module.getID()));

                            fs.readFile(path, "utf8", function (error, code) {
                                if (error) {
                                    throw error;
                                }

                                get(module.config, "exec")({
                                    callback: function () {
                                        // Clear anonymousDefine to ensure it is not reused
                                        // when the next module doesn't perform anonymous define(...)
                                        var args = anonymousDefine;
                                        anonymousDefine = null;
                                        callback(args);
                                    },
                                    code: code,
                                    path: path
                                });
                            });
                        }
                    });
                }(require));
            } else {
                global.require = modular.createRequirer();

                // Browser transport
                if (global.window && global.document) {
                    (function (document) {
                        var anonymousDefine,
                            callbacks = {},
                            defineAnonymous = function (args) {
                                anonymousDefine = args;
                            },
                            head = document.getElementsByTagName("head")[0],
                            useInteractiveScript = has.call(document, "uniqueID");

                        function load(script, args) {
                            var callback = callbacks[script.uniqueID];
                            if (callback) {
                                delete callbacks[script.uniqueID];
                                callback(args);
                            }
                        }

                        if (useInteractiveScript) {
                            defineAnonymous = function (args) {
                                util.each(document.getElementsByTagName("script"), function (script) {
                                    if (script.readyState === "interactive") {
                                        load(script, args);
                                        return false;
                                    }
                                });
                            };
                        }

                        modular.configure({
                            // TODO: Tests to ensure baseURI is respected (eg. when <base /> tag is on page)
                            "baseUrl": (document.baseURI || global.location.pathname).replace(/\/?[^\/]+$/, ""),
                            "defineAnonymous": defineAnonymous,
                            "exclude": /^(https?:)?\/\//,
                            "transport": function (callback, module) {
                                var script = document.createElement("script"),
                                    uri = makePath(get(module.config, "baseUrl"), module.getID());

                                if (get(module.config, "cache") === false) {
                                    uri += "?__r=" + Math.random();
                                }

                                if (useInteractiveScript) {
                                    callbacks[script.uniqueID] = callback;

                                    script.onreadystatechange = function () {
                                        if (script.readyState === "loaded") {
                                            load(script, null);
                                        }
                                    };
                                } else {
                                    script.onload = function () {
                                        // Clear anonymousDefine to ensure it is not reused
                                        // when the next module doesn't perform anonymous define(...)
                                        var args = anonymousDefine;
                                        anonymousDefine = null;
                                        callback(args);

                                        head.removeChild(script);
                                    };

                                    script.onerror = function () {
                                        var msg = 'Failed to load module "' + module.getID() + '"',
                                            dependentIDs = [];

                                        if (global.console) {
                                            util.each(modular.modules, function (dependent) {
                                                util.each(dependent.getDependencies(), function (dependency) {
                                                    if (dependency.getID() === module.getID()) {
                                                        dependentIDs.push(dependent.getID());
                                                    }
                                                });
                                            });

                                            if (dependentIDs.length) {
                                                msg += " for:\n- " + dependentIDs.join("\n- ");
                                            }

                                            global.console.error(msg);
                                        }

                                        head.removeChild(script);
                                    };
                                }

                                script.type = "text/javascript";
                                script.src = uri;
                                head.insertBefore(script, head.firstChild);
                            }
                        });
                    }(global.document));
                }
            }
        }

        function loadMain() {
            util.each(global.document.getElementsByTagName("script"), function (script) {
                var main = script.getAttribute("data-main");

                if (main) {
                    script.removeAttribute("data-main");
                    global.require(".", [main]);
                    return false;
                }
            });
        }

        if (!isNode) {
            if (global.addEventListener) {
                global.addEventListener("DOMContentLoaded", loadMain);
            } else {
                (function check() {
                    try {
                        global.document.documentElement.doScroll("left");
                    } catch (error) {
                        global.setTimeout(check);
                        return;
                    }

                    loadMain();
                }());
            }
        }
    }());
}());
