JSpec.describe('DelegatorClass', function () {

    before(function () {
        DelegatedExample = DelegatorClass.extend({
            events: {
                'div click': 'pushOne',
                'li click': 'pushTwo'
            },
            pushOne: function () { this.returns.push('one'); },
            pushTwo: function () { this.returns.push('two'); },
            init: function (ret) {
                this._super();  
                this.returns = ret;
            }
        });
    });

    before_each(function () {
        fix = element(fixture('fixtures/delegatorclass.html'));
        d = new DelegatedExample([]);
    });

    it('binds events as described in its events property', function () {
        expect(d.returns).should(be_empty);
        fix.click();
        expect(d.returns).should(eql, ["one"]);  
    });

    it('uses event delegation to bind the events', function () {
        expect(d.returns).should(be_empty);

        fix.eq(1).append("<li>Hi there, I'm new round here.</li>"); 
        fix.find("li").click();

        expect(d.returns).should(eql, ["two", "one", "two", "one", "two", "one"]); 
    });

});
