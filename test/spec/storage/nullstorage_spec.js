var assert = require('assertive-chai').assert;

var Storage = require('../../../src/storage');

describe('Storage.NullStorage', function () {
    var s = null,
        ann = null;

    beforeEach(function () {
        s = Storage.NullStorage();
        ann = {
            id: 123,
            some: 'data'
        };
    });

    it("#create() should return the created annotation", function () {
        var res = s.create(ann);
        assert.deepEqual(res, ann);
    });

    it("#create() should assign a locally unique id to created annotations", function () {
        var res1 = s.create({
            some: 'data'
        });
        assert.property(res1, 'id');

        var res2 = s.create({
            some: 'data'
        });
        assert.property(res2, 'id');

        assert.notEqual(res1.id, res2.id);
    });

    it("#update() should return the updated annotation", function () {
        var res = s.update(ann);
        assert.deepEqual(res, ann);
    });

    it("#delete() should return the deleted annotation", function () {
        var res = s["delete"](ann);
        assert.deepEqual(res, ann);
    });

    it("#query() should return empty query results", function () {
        var res = s.query({
            foo: 'bar',
            type: 'giraffe'
        });
        assert.deepEqual(res, {
            results: []
        });
    });
});
