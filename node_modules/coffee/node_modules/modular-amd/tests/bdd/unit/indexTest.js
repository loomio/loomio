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

/*global define */
define([
    "vendor/chai/chai",
    "vendor/sinon/sinon",
    "js/util"
], function (
    chai,
    sinon,
    util
) {
    "use strict";

    var expect = chai.expect;

    describe("Node index.js", function () {
        var dirname,
            fs,
            global,
            loadModule,
            MockFunction,
            modular,
            module,
            process,
            require;

        beforeEach(function (done) {
            global = {};

            util.get("/index.js", {cache: false}).then(function (js) {
                loadModule = function () {
                    /*jshint evil:true */
                    new Function("__dirname, Function, module, process, require", js).call(global, dirname, MockFunction, module, process, require);
                };
                done();
            });
        });

        util.each([
            {
                node: true,
                dirname: "/a/node/package",
                baseUrl: "/a/current/working/directory"
            },
            {
                node: false,
                dirname: "/another/node/package",
                baseUrl: "/a/second/current/working/directory"
            }
        ], function (scenario) {
            describe("when the environment is" + (scenario.node ? "": " not") + " Node", function () {
                beforeEach(function () {
                    if (scenario.node) {
                        dirname = scenario.dirname;
                        fs = {
                            readFileSync: sinon.stub()
                        };
                        module = {};
                        require = sinon.stub();

                        require.withArgs("fs").returns(fs);
                        fs.readFileSync.withArgs(scenario.dirname + "/js/Modular.js").returns("return __modular__;");

                        modular = {
                            configure: sinon.spy(),
                            createDefiner: sinon.stub(),
                            createRequirer: sinon.stub()
                        };

                        MockFunction = function () {};
                        MockFunction.prototype.call = function (global) {
                            global.require = sinon.stub().withArgs("modular").returns(modular);
                        };

                        process = {
                            cwd: sinon.stub().returns(scenario.baseUrl)
                        };
                    }
                });

                it("should not throw an error", function () {
                    expect(loadModule).to.not.throw();
                });

                describe("when it does not error", function () {
                    beforeEach(function () {
                        loadModule();
                    });

                    if (scenario.node) {
                        it("should export the Modular instance as module.exports", function () {
                            expect(module.exports).to.equal(modular);
                        });

                        describe("when configuring the Modular instance", function () {
                            it("should call Modular.configure(...)", function () {
                                expect(modular.configure).to.have.been.calledOnce;
                            });

                            it("should set the 'baseUrl' option correctly", function () {
                                expect(modular.configure).to.have.been.calledWith(sinon.match.hasOwn("baseUrl", scenario.baseUrl));
                            });

                            describe("with the 'transport' and 'defineAnonymous' options", function () {
                                var defineAnonymous,
                                    transport;

                                beforeEach(function () {
                                    var options;
                                    options = modular.configure.getCall(0).args[0];
                                    defineAnonymous = options.defineAnonymous;
                                    transport = options.transport;
                                });

                                describe("when requesting an undefined module through the transport", function () {
                                    var callback,
                                        module;

                                    beforeEach(function () {
                                        callback = sinon.spy();
                                        module = {
                                            config: {}
                                        };
                                    });

                                    util.each([
                                        {id: "mod/ule"},
                                        {id: "a/module"},
                                        {id: "mod/ded"}
                                    ], function (fixture) {
                                        describe("when the module's id is '" + fixture.id + "' and caching is " + (fixture.allowCached ? "" : "not ") + "allowed", function () {
                                            beforeEach(function () {
                                                module.config.baseUrl = scenario.baseUrl;
                                                module.id = fixture.id;

                                                transport(callback, module);
                                            });

                                            // ...
                                        });
                                    });
                                });
                            });
                        });
                    }
                });
            });
        });
    });
});
