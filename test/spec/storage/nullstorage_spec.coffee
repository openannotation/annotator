var Storage;

Storage = require('../../../src/storage');

describe('Storage.NullStorage', function() {
    var ann, s;
    s = null;
    ann = null;
    beforeEach(function() {
        s = Storage.NullStorage();
        return ann = {
            id: 123,
            some: 'data'
        };
    });
    it("#create() should return the created annotation", function() {
        var res;
        res = s.create(ann);
        return assert.deepEqual(res, ann);
    });
    it("#create() should assign a locally unique id to created annotations", function() {
        var res1, res2;
        res1 = s.create({
            some: 'data'
        });
        assert.property(res1, 'id');
        res2 = s.create({
            some: 'data'
        });
        assert.property(res2, 'id');
        return assert.notEqual(res1.id, res2.id);
    });
    it("#update() should return the updated annotation", function() {
        var res;
        res = s.update(ann);
        return assert.deepEqual(res, ann);
    });
    it("#delete() should return the deleted annotation", function() {
        var res;
        res = s["delete"](ann);
        return assert.deepEqual(res, ann);
    });
    return it("#query() should return empty query results", function() {
        var res;
        res = s.query({
            foo: 'bar',
            type: 'giraffe'
        });
        return assert.deepEqual(res, {
            results: []
        });
    });
});
