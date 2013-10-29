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

/*global __dirname, module, process, require */
(function (nodeRequire) {
    "use strict";

    var directory = __dirname,
        fs = nodeRequire("fs"),
        global = {},
        modular;

    (function () {
        /*jshint evil:true */
        new Function(fs.readFileSync(directory + "/js/Modular.js")).call(global);
    }());

    modular = global.require("modular");

    (function () {
        var anonymousDefine,
            define = modular.createDefiner(),
            require = modular.createRequirer();

        function makePath(baseURI, id) {
            if (/\?/.test(id)) {
                return id;
            }

            if (!/^(https?:)?\/\//.test(id)) {
                id = (baseURI ? baseURI.replace(/\/$/, "") + "/" : "") + id;
            }

            return id.replace(/\.js$/, "") + ".js";
        }

        modular.configure({
            "baseUrl": process.cwd(),
            "defineAnonymous": function (args) {
                anonymousDefine = args;
            },
            "exec": function (args) {
                /*jslint evil:true */
                new Function("define, require", args.code)(define, require);
                args.callback();
            },
            "transport": function (callback, module) {
                var path = fs.realpathSync(makePath(module.config.baseUrl, module.id));

                fs.readFile(path, "utf8", function (error, code) {
                    if (error) {
                        throw error;
                    }

                    module.config.exec({
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
    }());

    module.exports = modular;
}(require));
