require("spec_helper.js");
require("../../js/jqext.js");

Screw.Unit(function() {
    describe("Delegator Class", function() {

        var DelegatedExample = DelegatorClass.extend({
            events: {
                'body click': 'pushOne',
                'li click': 'pushTwo'
            },
            returns: [],
            pushOne: function () { this.returns.push('one'); },
            pushTwo: function () { this.returns.push('two'); }
        });

        before(function () {
            d = new DelegatedExample();
        });

        it("binds events as described in its events property", function () {
            d.returns = [];
            expect(d.returns).to(equal, []);

            $('body').click();
            expect(d.returns).to(equal, ['one']);
        });

        it("uses event delegation to bind the events", function () {
            d.returns = [];
            expect(d.returns).to(equal, []);

            $('#fixtures li').click();
            expect(d.returns).to(equal, ['two', 'one', 'two', 'one']);

            d.returns = [];
            $('ul#fixtures').append("<li>Hi there, I'm new round here.</li>");
            $('#fixtures li').click();
            expect(d.returns).to(equal, ['two', 'one', 'two', 'one', 'two', 'one']);
        });
    });
});

