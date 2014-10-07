var h = require('helpers');

var $ = require('../../../src/util').$;

var DefaultUI = require('../../../src/plugin/defaultui').DefaultUI;

describe('DefaultUI plugin', function () {
    it('should add CSS to the document that ensures annotator elements have a suitably high z-index', function () {
        h.addFixture('annotator');
        var $fix = $(h.fix());
        $fix.show();

        var $adder = $('<div style="position:relative;" class="annotator-adder">&nbsp;</div>').appendTo($fix);
        var $filter = $('<div style="position:relative;" class="annotator-filter">&nbsp;</div>').appendTo($fix);

        function check(minimum) {
            var adderZ, filterZ;
            adderZ = parseInt($adder.css('z-index'), 10);
            filterZ = parseInt($filter.css('z-index'), 10);
            assert.operator(adderZ, '>', minimum);
            assert.operator(filterZ, '>', minimum);
            return assert.operator(adderZ, '>', filterZ);
        }

        var plug = DefaultUI(h.fix())(null);
        check(1000);

        $fix.append('<div style="position: relative; z-index: 2000"></div>');
        plug = DefaultUI(h.fix())(null);
        check(2000);
    });

    it("should remove its elements from the page when destroyed", function () {
        var el = $('<div></div>')[0];
        var plug = DefaultUI(el)(null);
        plug.onDestroy();
        assert.equal($(el).find('[class^=annotator-]').length, 0);
    });
});
