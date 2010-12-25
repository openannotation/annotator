(function() {
  var $, DelegatedExample;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  $ = jQuery;
  DelegatedExample = (function() {
    __extends(DelegatedExample, Delegator);
    DelegatedExample.prototype.events = {
      'div click': 'pushA',
      'baz': 'pushB'
    };
    function DelegatedExample(elem) {
      DelegatedExample.__super__.constructor.apply(this, arguments);
      this.returns = [];
      this.addEvents();
    }
    DelegatedExample.prototype.pushA = function() {
      return this.returns.push("A");
    };
    DelegatedExample.prototype.pushB = function() {
      return this.returns.push("B");
    };
    DelegatedExample.prototype.pushC = function() {
      return this.returns.push("C");
    };
    return DelegatedExample;
  })();
  describe('DelegatorClass', function() {
    var $fix, d;
    d = null;
    $fix = null;
    beforeEach(function() {
      addFixture('delegatorclass');
      d = new DelegatedExample(fix());
      return $fix = $(fix());
    });
    afterEach(function() {
      return clearFixtures();
    });
    describe("addEvent", function() {
      it("adds an event for a selector", function() {
        d.addEvent('p', 'foo', 'pushC');
        $fix.find('p').trigger('foo');
        return expect(d.returns).toEqual(['C']);
      });
      it("adds an event for an element", function() {
        d.addEvent($fix.find('p').get(0), 'bar', 'pushC');
        $fix.find('p').trigger('bar');
        return expect(d.returns).toEqual(['C']);
      });
      return it("uses event delegation to bind the events", function() {
        d.addEvent('li', 'click', 'pushB');
        $fix.find('ol').append("<li>Hi there, I'm new round here.</li>");
        $fix.find('li').click();
        return expect(d.returns).toEqual(['B', 'A', 'B', 'A']);
      });
    });
    it("automatically binds events described in its events property", function() {
      $fix.find('p').click();
      return expect(d.returns).toEqual(['A']);
    });
    return it("will bind events in its events property to its root element if no selector is specified", function() {
      $fix.trigger('baz');
      return expect(d.returns).toEqual(['B']);
    });
  });
}).call(this);
