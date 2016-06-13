// Disable cyclomatic complexity checking for this file
// jshint -W074

var xpath = require('xpath-range').xpath;

var util = require('../src/util');
var $ = util.$;

function contains(parent, child) {
    var node;
    node = child;
    while (node !== null) {
        if (node === parent) {
            return true;
        }
        node = node.parentNode;
    }
    return false;
}

function MockSelection(fixElem, data) {
    this.rangeCount = 0;
    this.isCollapsed = false;
    this.root = fixElem;
    this.rootXPath = xpath.fromNode($(fixElem))[0];
    this.startContainer = this.resolvePath(data[0]);
    this.startOffset = data[1];
    this.endContainer = this.resolvePath(data[2]);
    this.endOffset = data[3];
    this.expectation = data[4];
    this.description = data[5];
    this.commonAncestor = this.startContainer;

    while (!contains(this.commonAncestor, this.endContainer)) {
        this.commonAncestor = this.commonAncestor.parentNode;
    }
    this.commonAncestorXPath = xpath.fromNode($(this.commonAncestor))[0];

    this.ranges = [];
    this.addRange({
        startContainer: this.startContainer,
        startOffset: this.startOffset,
        endContainer: this.endContainer,
        endOffset: this.endOffset,
        commonAncestorContainer: this.commonAncestor
    });
}

MockSelection.prototype.getRangeAt = function (i) {
    return this.ranges[i];
};

MockSelection.prototype.removeAllRanges = function () {
    this.ranges = [];
    this.rangeCount = 0;
};

MockSelection.prototype.addRange = function (r) {
    this.ranges.push(r);
    this.rangeCount += 1;
};

MockSelection.prototype.resolvePath = function (path) {
    if (typeof path === "number") {
        return util.getTextNodes($(this.root))[path];
    } else if (typeof path === "string") {
        return this.resolveXPath(this.rootXPath + path);
    }
};

MockSelection.prototype.resolveXPath = function (xpath) {
    return document.evaluate(xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
};

function textInNormedRange(range) {
    var textNodes = util.getTextNodes($(range.commonAncestor));
    textNodes = textNodes.slice(
        textNodes.index(range.start),
        textNodes.index(range.end) + 1 || 9e9
    ).get();
    return textNodes.reduce((function (acc, next) {
        return acc += next.nodeValue;
    }), "");
}

function DateToISO8601String(format, offset) {
    /*
    accepted values for the format [1-6]:
     1 Year:
         YYYY (eg 1997)
     2 Year and month:
         YYYY-MM (eg 1997-07)
     3 Complete date:
         YYYY-MM-DD (eg 1997-07-16)
     4 Complete date plus hours and minutes:
         YYYY-MM-DDThh:mmTZD (eg 1997-07-16T19:20+01:00)
     5 Complete date plus hours, minutes and seconds:
         YYYY-MM-DDThh:mm:ssTZD (eg 1997-07-16T19:20:30+01:00)
     6 Complete date plus hours, minutes, seconds and a decimal
         fraction of a second
         YYYY-MM-DDThh:mm:ss.sTZD (eg 1997-07-16T19:20:30.45+01:00)
    */
    var d, date, offsetnum, secs, str, zeropad;
    if (typeof format == 'undefined' || format === null) {
        format = 6;
    }

    if (!offset) {
        offset = 'Z';
        date = this;
    } else {
        d = offset.match(/([-+])([0-9]{2}):([0-9]{2})/);
        offsetnum = (Number(d[2]) * 60) + Number(d[3]);
        offsetnum *= d[1] === '-' ? -1 : 1;
        date = new Date(Number(Number(this) + (offsetnum * 60000)));
    }
    zeropad = function (num) {
        return (num < 10 ? '0' : '') + num;
    };
    str = "";
    str += date.getUTCFullYear();
    if (format > 1) {
        str += "-" + zeropad(date.getUTCMonth() + 1);
    }
    if (format > 2) {
        str += "-" + zeropad(date.getUTCDate());
    }
    if (format > 3) {
        str += "T" + zeropad(date.getUTCHours()) + ":" + zeropad(date.getUTCMinutes());
    }
    if (format > 5) {
        secs = Number(date.getUTCSeconds() + "." + (date.getUTCMilliseconds() < 100 ? '0' : '') + zeropad(date.getUTCMilliseconds()));
        str += ":" + zeropad(secs);
    } else if (format > 4) {
        str += ":" + zeropad(date.getUTCSeconds());
    }
    if (format > 3) {
        str += offset;
    }
    return str;
}

var fixtureElem = $('<div id="fixtures"></div>').appendTo('body')[0];
var fixtureMemo = {};

function setFixtureElem(elem) {
    fixtureElem = elem;
}

function fix() {
    return fixtureElem;
}

function getFixture(fname) {
    if (!(fname in fixtureMemo)) {
        fixtureMemo[fname] = $.ajax({
            url: "/base/test/fixtures/" + fname + ".html",
            async: false
        }).responseText;
    }
    return fixtureMemo[fname];
}

function addFixture(fname) {
    $(getFixture(fname)).appendTo(fixtureElem);
}

function clearFixtures() {
    $(fixtureElem).remove();
    fixtureElem = $('<div id="fixtures"></div>').appendTo('body')[0];
}


exports.DateToISO8601String = DateToISO8601String;
exports.MockSelection = MockSelection;
exports.addFixture = addFixture;
exports.clearFixtures = clearFixtures;
exports.fix = fix;
exports.getFixture = getFixture;
exports.setFixtureElem = setFixtureElem;
exports.textInNormedRange = textInNormedRange;
