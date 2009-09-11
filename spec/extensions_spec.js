JSpec.describe('Extensions', function () {
    it('adds an inject method to the jQuery object', function () {
        result = $.inject([1, 2, 3, 4], 0, function (acc, val, idx) {
            return acc + val;
        });
        expect(result).should(eql, 10);
    });

    it('adds a flatten method to the jQuery object', function () {
        result = $.flatten([1, [2, 3, [{four: 4}]], 5, [[6], 7]]);
        expect(result).should(eql, [1, 2, 3, {four: 4}, 5, 6, 7]);
    });

    it('adds a jQuery function to return an element\'s textNode descendants', function () {
        fix = $(fixture('fixtures/textnodes.html')).get(0).parentNode;

        allText = $.inject($(fix).textNodes(), "", function (acc, node) {
            return acc + node.nodeValue;
        }).replace(/\s+/g, ' ');

        expect($(fix).textNodes()).should(have_length, 12);
        expect(allText).should(eql, ' lorem ipsum dolor sit dolor sit amet. humpty dumpty. etc. ');
    });

    describe('XPath generator', function () {
        before_each(function () {
            fix = $(fixture('fixtures/xpath.html')).get(0).parentNode;
        });

        it('generates an XPath string for an element\'s position in the document', function () {
            expect($(fix).find('p').xpath()).should(eql, ['/div/p', '/div/p[2]']);
            expect($(fix).find('span').xpath()).should(eql, ['/div/ol/li[2]/span']);
            expect($(fix).find('strong').xpath()).should(eql, ['/div/p[2]/strong']);
        });

        it('takes an optional root-element parameter', function () {
            ol = $(fix).find('ol').get(0);
            expect($(fix).find('li').xpath(ol)).should(eql, ['/ol/li', '/ol/li[2]', '/ol/li[3]']);
            expect($(fix).find('span').xpath(ol)).should(eql, ['/ol/li[2]/span']);
        });
    });
});

JSpec.describe('DelegatorClass', function () {

    before(function () {
        DelegatedExample = DelegatorClass.extend({
            events: {
                'div click': 'pushA'
            },
            init: function (elem, ret) {
                var self = this;

                this.element = elem;
                this.returns = ret;

                $.each(['A', 'B', 'C'], function (idx, val) {
                    self['push' + val] = function () { self.returns.push(val); };
                });

                this._super();
            }
        });
    });

    before_each(function () {
        fix = $(fixture('fixtures/delegatorclass.html')).get(0).parentNode;
        d = new DelegatedExample(fix, []);
    });

    describe('addDelegatedEvent', function () {
        it('adds an event for a selector', function () {
            d.addDelegatedEvent('p', 'foo', 'pushC');

            expect(d.returns).should(be_empty);
            $(fix).find('p').trigger('foo');
            expect(d.returns).should(eql, ['C']);
        });

        it('adds an event for an element', function () {
            d.addDelegatedEvent($(fix).find('p').get(0), 'bar', 'pushC');

            expect(d.returns).should(be_empty);
            $(fix).find('p').trigger('bar');
            expect(d.returns).should(eql, ['C']);
        });

        it('uses event delegation to bind the events', function () {
            d.addDelegatedEvent('li', 'click', 'pushB');

            expect(d.returns).should(be_empty);

            $(fix).find('ol').append("<li>Hi there, I'm new round here.</li>");
            $(fix).find('li').click();

            expect(d.returns).should(eql, ['A', 'B', 'A', 'B']);
        });
    });

    it('automatically binds events described in its events property', function () {
        expect(d.returns).should(be_empty);
        $(fix).click();
        expect(d.returns).should(eql, ['A']);
    });


});
