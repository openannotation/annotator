var $, DefaultUI, h;

h = require('helpers');

$ = require('../../../src/util').$;

DefaultUI = require('../../../src/plugin/defaultui').DefaultUI;

describe('DefaultUI plugin', function() {
    it('should add CSS to the document that ensures annotator elements have a suitably high z-index', function() {
        var $adder, $filter, $fix, check, plug;
        h.addFixture('annotator');
        $fix = $(h.fix());
        $fix.show();
        $adder = $('<div style="position:relative;" class="annotator-adder">&nbsp;</div>').appendTo($fix);
        $filter = $('<div style="position:relative;" class="annotator-filter">&nbsp;</div>').appendTo($fix);
        check = function(minimum) {
            var adderZ, filterZ;
            adderZ = parseInt($adder.css('z-index'), 10);
            filterZ = parseInt($filter.css('z-index'), 10);
            assert.operator(adderZ, '>', minimum);
            assert.operator(filterZ, '>', minimum);
            return assert.operator(adderZ, '>', filterZ);
        };
        plug = DefaultUI(h.fix())(null);
        check(1000);
        $fix.append('<div style="position: relative; z-index: 2000"></div>');
        plug = DefaultUI(h.fix())(null);
        return check(2000);
    });
    return it("should remove its elements from the page when destroyed", function() {
        var el, plug;
        el = $('<div></div>')[0];
        plug = DefaultUI(el)(null);
        plug.onDestroy();
        return assert.equal($(el).find('[class^=annotator-]').length, 0);
    });
});
