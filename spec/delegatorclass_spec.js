JSpec.describe('DelegatorClass', function () {

    before(function () {
        DelegatedExample = DelegatorClass.extend({
            events: {
                'div click': 'pushA',
            },
            init: function (elem, ret) {
                var self = this;

                this.element = elem;
                this.returns = ret;

                $.each(['A', 'B', 'C'], function (idx, val) {
                    self['push' + val] = function () { self.returns.push(val) };
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
