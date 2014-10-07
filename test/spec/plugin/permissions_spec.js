var Annotator = require('annotator'),
    Permissions = require('../../../src/plugin/permissions');

var $ = Annotator.Util.$;

describe('Permissions plugin', function () {
    var el = null,
        annotator = null,
        permissions = null;

    beforeEach(function () {
        el = $("<div class='annotator-viewer'></div>").appendTo('body')[0];
        annotator = new Annotator($('<div/>')[0]);
        permissions = new Permissions(el);
        permissions.annotator = annotator;
        permissions.pluginInit();
    });

    afterEach(function () {
        annotator.destroy();
        permissions.destroy();
        $(el).remove();
    });

    it("it should add the current user object to newly created annotations on beforeAnnotationCreated", function () {
        var ann = {};
        annotator.publish('beforeAnnotationCreated', [ann]);
        assert.isUndefined(ann.user);

        ann = {};
        permissions.setUser('alice');
        annotator.publish('beforeAnnotationCreated', [ann]);
        assert.equal(ann.user, 'alice');

        ann = {};
        permissions.setUser({
            id: 'alice'
        });
        permissions.options.userId = function (user) {
            return user.id;
        };
        annotator.publish('beforeAnnotationCreated', [ann]);
        assert.deepEqual(ann.user, {
            id: 'alice'
        });
    });

    it("it should add permissions to newly created annotations on beforeAnnotationCreated", function () {
        var ann = {};
        annotator.publish('beforeAnnotationCreated', [ann]);
        assert.ok(ann.permissions);

        ann = {};
        permissions.options.permissions = {};
        annotator.publish('beforeAnnotationCreated', [ann]);
        assert.deepEqual(ann.permissions, {});
    });

    describe('pluginInit', function () {
        beforeEach(function () {
            sinon.stub(annotator.viewer, 'addField');
            sinon.stub(annotator.editor, 'addField');
        });

        afterEach(function () {
            annotator.viewer.addField.reset();
            annotator.editor.addField.reset();
        });

        it("should register a field with the Viewer", function () {
            permissions.pluginInit();
            assert(annotator.viewer.addField.calledOnce);
        });

        it("should register an two checkbox fields with the Editor", function () {
            permissions.pluginInit();
            assert.equal(annotator.editor.addField.callCount, 2);
        });

        it("should register an 'anyone can view' field with the Editor if showEditPermissionsCheckbox is true", function () {
            permissions.options.showViewPermissionsCheckbox = true;
            permissions.options.showEditPermissionsCheckbox = false;
            permissions.pluginInit();
            assert.equal(annotator.editor.addField.callCount, 1);
        });

        it("should register an 'anyone can edit' field with the Editor if showViewPermissionsCheckbox is true", function () {
            permissions.options.showViewPermissionsCheckbox = false;
            permissions.options.showEditPermissionsCheckbox = true;
            permissions.pluginInit();
            assert.equal(permissions.annotator.editor.addField.callCount, 1);
        });

        it("should register a filter if the Filter plugin is loaded", function () {
            permissions.annotator.plugins.Filter = {
                addFilter: sinon.spy()
            };
            permissions.pluginInit();
            assert(permissions.annotator.plugins.Filter.addFilter.calledOnce);
        });
    });

    describe('authorize', function () {
        var annotations = null;

        describe('Basic usage', function () {
            beforeEach(function () {
                annotations = [
                    {},
                    {user: 'alice'},
                    {permissions: {}},
                    {permissions: {'update': []}}
                ];
            });

            it('should allow any action for an annotation with no authorisation info', function () {
                var a = annotations[0];
                assert.isTrue(permissions.authorize(null, a));
                assert.isTrue(permissions.authorize('foo', a));
                permissions.setUser('alice');
                assert.isTrue(permissions.authorize(null, a));
                assert.isTrue(permissions.authorize('foo', a));
            });

            it('should NOT allow any action if annotation.user and no @user is set', function () {
                var a = annotations[1];
                assert.isFalse(permissions.authorize(null, a));
                assert.isFalse(permissions.authorize('foo', a));
            });

            it('should allow any action if @options.userId(@user) == annotation.user', function () {
                var a = annotations[1];
                permissions.setUser('alice');
                assert.isTrue(permissions.authorize(null, a));
                assert.isTrue(permissions.authorize('foo', a));
            });

            it('should NOT allow any action if @options.userId(@user) != annotation.user', function () {
                var a = annotations[1];
                permissions.setUser('bob');
                assert.isFalse(permissions.authorize(null, a));
                assert.isFalse(permissions.authorize('foo', a));
            });

            it('should allow any action if annotation.permissions == {}', function () {
                var a = annotations[2];
                assert.isTrue(permissions.authorize(null, a));
                assert.isTrue(permissions.authorize('foo', a));
                permissions.setUser('alice');
                assert.isTrue(permissions.authorize(null, a));
                assert.isTrue(permissions.authorize('foo', a));
            });

            it('should allow an action if annotation.permissions[action] == []', function () {
                var a = annotations[3];
                assert.isTrue(permissions.authorize('update', a));
                permissions.setUser('bob');
                assert.isTrue(permissions.authorize('update', a));
            });
        });

        describe('Custom options.userAuthorize() callback', function () {
            beforeEach(function () {
                permissions.setUser(null);
                // Define a custom userAuthorize method to allow a more complex system
                //
                // This test is to ensure that the Permissions plugin can still handle
                // users and groups as it did in a legacy version (commit fc22b76 and
                // earlier).
                //
                // Here we allow custom permissions tokens that can handle both users
                // and groups in the form "user:username" and "group:groupname". We
                // then proved an options.userAuthorize() method that recieves a user
                // and token and returns true if the current user meets the requirements
                // set by the token.
                //
                // In this example it is assumed that all users (if present) are objects
                // with an "id" and optional "groups" property. The group will default
                // to "public" which means anyone can edit it.
                permissions.options.userAuthorize = function (action, annotation, user) {
                    function userGroups(user) {
                        var groups = ['public'];
                        if (typeof user != 'undefined' && user !== null &&
                            typeof user.groups != 'undefined' && user.groups !== null) {
                            groups = user.groups;
                        }
                        return groups;
                    }

                    function tokenTest(token, user) {
                        if (/^(?:group|user):/.test(token)) {
                            var splitTok = token.split(':'),
                                key = splitTok[0],
                                values = [];

                            if (splitTok.length > 1) {
                                values = splitTok.slice(1);
                            }
                            var value = values.join(':');

                            if (key === 'group') {
                                var groups = userGroups(user);
                                return (groups.indexOf(value) >= 0);
                            } else if (user && key === 'user') {
                                return value === user.id;
                            }
                        }
                    }

                    if (annotation.permissions) {
                        var tokens = annotation.permissions[action] || [];
                        for (var i = 0, len = tokens.length; i < len; i++) {
                            var token = tokens[i];
                            if (tokenTest(token, user)) {
                                return true;
                            }
                        }
                    }
                    return false;
                };

                annotations = [
                    {permissions: {'update': ['group:public']}},
                    {permissions: {'update': ['user:alice']}},
                    {permissions: {'update': ['user:alice', 'user:bob']}},
                    {permissions: {'update': ['user:alice', 'user:bob', 'group:admin']}}
                ];
            });

            afterEach(function () {
                delete permissions.options.userAuthorize;
            });

            it('should (by default) allow an action if annotation.permissions[action] includes "group:public"', function () {
                var a = annotations[0];
                assert.isTrue(permissions.authorize('update', a));
                permissions.setUser({
                    id: 'bob'
                });
                assert.isTrue(permissions.authorize('update', a));
            });
            it('should (by default) allow an action if annotation.permissions[action] includes "user:@user"', function () {
                var a = annotations[1];
                assert.isFalse(permissions.authorize('update', a));

                permissions.setUser({
                    id: 'bob'
                });
                assert.isFalse(permissions.authorize('update', a));

                permissions.setUser({
                    id: 'alice'
                });
                assert.isTrue(permissions.authorize('update', a));

                a = annotations[2];
                permissions.setUser(null);
                assert.isFalse(permissions.authorize('update', a));

                permissions.setUser({
                    id: 'bob'
                });
                assert.isTrue(permissions.authorize('update', a));

                permissions.setUser({
                    id: 'alice'
                });
                assert.isTrue(permissions.authorize('update', a));
            });

            it('should allow an action if annotation.permissions[action] includes "user:@options.userId(@user)"', function () {
                var a = annotations[1];
                permissions.options.userId = function (user) {
                    if (typeof user == 'undefined' || user === null) {
                        return null;
                    }
                    if (typeof user.id == 'undefined') {
                        return null;
                    }
                    return user.id;
                };
                assert.isFalse(permissions.authorize('update', a));
                permissions.setUser({
                    id: 'alice'
                });
                assert.isTrue(permissions.authorize('update', a));
            });

            it('should allow an action if annotation.permissions[action] includes "user:@options.userId(@user)"', function () {
                var a = annotations[3];
                assert.isFalse(permissions.authorize('update', a));

                permissions.setUser({
                    id: 'foo',
                    groups: ['other']
                });
                assert.isFalse(permissions.authorize('update', a));

                permissions.setUser({
                    id: 'charlie',
                    groups: ['admin']
                });
                assert.isTrue(permissions.authorize('update', a));
            });
        });
    });

    describe('updateAnnotationPermissions', function () {
        var field = null,
            checkbox = null,
            annotation = null;

        beforeEach(function () {
            checkbox = $('<input type="checkbox" />');
            field = $('<li />').append(checkbox)[0];
            annotation = {
                permissions: {
                    'update': ['Alice']
                }
            };
        });

        it("should NOT be world editable when 'Anyone can edit' checkbox is unchecked", function () {
            checkbox.removeAttr('checked');
            permissions.updateAnnotationPermissions('update', field, annotation);
            assert.isFalse(permissions.authorize('update', annotation, null));
        });

        it("should be world editable when 'Anyone can edit' checkbox is checked", function () {
            checkbox.attr('checked', 'checked');
            permissions.updateAnnotationPermissions('update', field, annotation);
            assert.isTrue(permissions.authorize('update', annotation, null));
        });

        it("should NOT be world editable when 'Anyone can edit' checkbox is unchecked for a second time", function () {
            checkbox.attr('checked', 'checked');
            permissions.updateAnnotationPermissions('update', field, annotation);
            assert.isTrue(permissions.authorize('update', annotation, null));

            checkbox.removeAttr('checked');
            permissions.updateAnnotationPermissions('update', field, annotation);
            assert.isFalse(permissions.authorize('update', annotation, null));
        });

        it('should consult the userId option when updating permissions', function () {
            annotation = {
                permissions: {}
            };
            permissions.options.userId = function (user) {
                return user.id;
            };
            permissions.setUser({
                id: 3,
                name: 'Alice'
            });
            permissions.updateAnnotationPermissions('update', field, annotation);
            assert.deepEqual(annotation.permissions, {
                'update': [3]
            });
        });
    });

    describe('updatePermissionsField', function () {
        var field = null,
            checkbox = null,
            annotations = [
                {},
                {permissions: {'update': ['user:Alice']}},
                {permissions: {'update': ['user:Alice']}},
                {permissions: {'update': ['Alice'], 'admin': ['Alice']}},
                {permissions: {'update': ['Alice'], 'admin': ['Bob']}}
            ];

        beforeEach(function () {
            checkbox = $('<input type="checkbox" />');
            field = $('<li />').append(checkbox).appendTo(permissions.element);
            permissions.setUser('Alice');
            permissions.updatePermissionsField('update', field, annotations.shift());
        });

        afterEach(function () {
            field.remove();
        });

        it("should have a checked checkbox when there are no permissions", function () {
            assert.isTrue(checkbox.is(':checked'));
        });

        it("should have an unchecked checkbox when there are permissions", function () {
            assert.isFalse(checkbox.is(':checked'));
        });

        it("should enable the checkbox by default", function () {
            assert.isTrue(checkbox.is(':enabled'));
        });

        it("should display the field if the current user has 'admin' permissions", function () {
            assert.isTrue(field.is(':visible'));
        });

        it("should NOT display the field if the current user does not have 'admin' permissions", function () {
            assert.isFalse(field.is(':visible'));
        });
    });

    describe('updateViewer', function () {
        var controls = null,
            field = null;

        beforeEach(function () {
            field = $('<div />').appendTo('<div />')[0];
            controls = {
                showEdit: sinon.spy(),
                hideEdit: sinon.spy(),
                showDelete: sinon.spy(),
                hideDelete: sinon.spy()
            };
        });

        describe('coarse grained updates based on user', function () {
            var annotations = null;

            beforeEach(function () {
                permissions.setUser('alice');
                annotations = [{user: 'alice'}, {user: 'bob'}, {}];
            });

            it("it should display annotations' users in the viewer element", function () {
                permissions.updateViewer(field, annotations[0], controls);
                assert.equal($(field).html(), 'alice');
                assert.lengthOf($(field).parent(), 1);
            });

            it("it should remove the field if annotation has no user", function () {
                permissions.updateViewer(field, {}, controls);
                assert.lengthOf($(field).parent(), 0);
            });

            it("it should remove the field if annotation has no user string", function () {
                permissions.options.userString = function () { return null; };
                permissions.updateViewer(field, annotations[1], controls);
                assert.lengthOf($(field).parent(), 0);
            });

            it("it should remove the field if annotation has empty user string", function () {
                permissions.options.userString = function () { return ''; };
                permissions.updateViewer(field, annotations[1], controls);
                assert.lengthOf($(field).parent(), 0);
            });

            it("should hide controls for users other than the current user", function () {
                permissions.updateViewer(field, annotations[0], controls);
                assert.isFalse(controls.hideEdit.called);
                assert.isFalse(controls.hideDelete.called);
                permissions.updateViewer(field, annotations[1], controls);
                assert(controls.hideEdit.calledOnce);
                assert(controls.hideDelete.calledOnce);
            });

            it("should show controls for annotations without a user", function () {
                permissions.updateViewer(field, annotations[2], controls);
                assert.isFalse(controls.hideEdit.called);
                assert.isFalse(controls.hideDelete.called);
            });
        });

        describe('fine-grained use (user and permissions)', function () {
            var annotations = null;

            beforeEach(function () {
                annotations = [
                    {user: 'alice', permissions: {'update': ['alice'], 'delete': ['alice']}},
                    {user: 'bob', permissions: {'update': ['bob'], 'delete': ['bob']}}
                ];
                permissions.setUser('bob');
            });

            it("it should should hide edit button if user cannot update", function () {
                permissions.updateViewer(field, annotations[0], controls);
                assert(controls.hideEdit.calledOnce);
            });

            it("it should should show edit button if user can update", function () {
                permissions.updateViewer(field, annotations[1], controls);
                assert.isFalse(controls.hideEdit.called);
            });

            it("it should should hide delete button if user cannot delete", function () {
                permissions.updateViewer(field, annotations[0], controls);
                assert(controls.hideDelete.calledOnce);
            });

            it("it should should show delete button if user can delete", function () {
                permissions.updateViewer(field, annotations[1], controls);
                assert.isFalse(controls.hideDelete.called);
            });
        });
    });
});
