var assert = require('assertive-chai').assert;
var util = require('../../../src/util');
var doc = require('../../../src/ext/document');

var $ = util.$;

var FIXTURE_METADATA = {
    links: [
        '<link rel="alternate" href="foo.pdf" type="application/pdf"></link>',
        '<link rel="alternate" href="foo.doc" type="application/msword"></link>',
        '<link rel="bookmark" href="http://example.com/bookmark"></link>',
        '<link rel="alternate" href="es/foo.html" hreflang="es" type="text/html"></link>',
        '<link rel="alternate" href="feed" type="application/rss+xml"></link>',
        '<link rel="canonical" href="http://example.com/bookmark/canonical.html"></link>',
        '<link rel="shortlink" href="http://example.com/bookmark/short"></link>'
    ],
    highwire: [
        '<meta name="citation_doi" content="10.1175/JCLI-D-11-00015.1">',
        '<meta name="citation_title" content="Foo">',
        '<meta name="citation_pdf_url" content="foo.pdf">'
    ],
    dc: [
        '<meta name="dc.identifier" content="doi:10.1175/JCLI-D-11-00015.1">',
        '<meta name="dc.identifier" content="isbn:123456789">',
        '<meta name="DC.type" content="Article">'
    ],
    facebook: ['<meta property="og:url" content="http://example.com">'],
    twitter: ['<meta name="twitter:site" content="@okfn">'],
    favicon: ['<link rel="icon" href="http://example.com/images/icon.ico"></link>'],
    eprints: ['<meta name="eprints.title" content="Computer Lib / Dream Machines">'],
    prism: ['<meta name="prism.title" content="Literary Machines">']
};

describe('annotator.ext.document module', function () {
    var tags = null,
        metadata = null;

    it('adds document metadata to the annotation beforeAnnotationCreated', function () {
        var plugin = doc.document();
        var annotation = {};
        plugin.beforeAnnotationCreated(annotation);
        assert.property(annotation, 'document');
    });

    describe('getDocumentMetadata() returned metadata', function () {
        // Add some metadata tags to the document head
        beforeEach(function () {
            tags = [];
            for (var name in FIXTURE_METADATA) {
                var t = FIXTURE_METADATA[name];
                var html = t.join('\n');
                tags[name] = $(html).appendTo('head');
            }
            metadata = doc.getDocumentMetadata();
        });

        afterEach(function () {
            // Remove tags from document head
            for (var name in tags) {
                tags[name].remove();
            }
        });

        it('should have links with absolute hrefs and types', function () {
            assert.ok(metadata.link);
            assert.equal(metadata.link.length, 9);
            assert.equal(metadata.link[0].href, window.location.href);
            assert.equal(metadata.link[1].rel, "alternate");
            assert.match(metadata.link[1].href, /^.+foo\.pdf$/);
            assert.equal(metadata.link[1].type, "application/pdf");
            assert.equal(metadata.link[2].rel, "alternate");
            assert.match(metadata.link[2].href, /^.+foo\.doc$/);
            assert.equal(metadata.link[2].type, "application/msword");
            assert.equal(metadata.link[3].rel, "bookmark");
            assert.equal(metadata.link[3].href, "http://example.com/bookmark");
            assert.equal(metadata.link[4].rel, "canonical");
            assert.equal(metadata.link[4].href, "http://example.com/bookmark/canonical.html");
            assert.equal(metadata.link[5].rel, "shortlink");
            assert.equal(metadata.link[5].href, "http://example.com/bookmark/short");
            assert.equal(metadata.link[6].href, "doi:10.1175/JCLI-D-11-00015.1");
            assert.match(metadata.link[7].href, /.+foo\.pdf$/);
            assert.equal(metadata.link[7].type, "application/pdf");
            assert.equal(metadata.link[8].href, "doi:10.1175/JCLI-D-11-00015.1");
        });

        it('should ignore atom and RSS feeds and alternate languages', function () {
            assert.equal(metadata.link.length, 9);
        });

        it('should have highwire metadata', function () {
            assert.ok(metadata.highwire);
            // jscs:disable requireCamelCaseOrUpperCaseIdentifiers
            assert.deepEqual(metadata.highwire.pdf_url, ['foo.pdf']);
            // jscs:enable requireCamelCaseOrUpperCaseIdentifiers
            assert.deepEqual(metadata.highwire.doi, ['10.1175/JCLI-D-11-00015.1']);
            assert.deepEqual(metadata.highwire.title, ['Foo']);
        });

        it('should have dublincore metadata', function () {
            assert.ok(metadata.dc);
            assert.deepEqual(metadata.dc.identifier, ["doi:10.1175/JCLI-D-11-00015.1", "isbn:123456789"]);
            assert.deepEqual(metadata.dc.type, ["Article"]);
        });

        it('should have facebook metadata', function () {
            assert.ok(metadata.facebook);
            assert.deepEqual(metadata.facebook.url, ["http://example.com"]);
        });

        it('should have eprints metadata', function () {
            assert.ok(metadata.eprints);
            assert.deepEqual(metadata.eprints.title, ['Computer Lib / Dream Machines']);
        });

        it('should have prism metadata', function () {
            assert.ok(metadata.prism);
            assert.deepEqual(metadata.prism.title, ['Literary Machines']);
        });

        it('should have twitter card metadata', function () {
            assert.ok(metadata.twitter);
            assert.deepEqual(metadata.twitter.site, ['@okfn']);
        });

        it('should have a favicon', function () {
            assert.equal(metadata.favicon, 'http://example.com/images/icon.ico');
        });

        it('does not have empty fields for nonexistent metadata', function () {
            tags.highwire.remove();
            tags.facebook.remove();
            metadata = doc.getDocumentMetadata();
            assert.isUndefined(metadata.highwire);
            assert.isUndefined(metadata.facebook);
        });

        it('has a title derived from metadata, in preference order', function () {
            metadata = doc.getDocumentMetadata();
            assert.strictEqual(metadata.title, 'Foo');
            tags.highwire.remove();
            metadata = doc.getDocumentMetadata();
            assert.strictEqual(metadata.title, 'Computer Lib / Dream Machines');
            tags.eprints.remove();
            metadata = doc.getDocumentMetadata();
            assert.strictEqual(metadata.title, 'Literary Machines');
        });

        it('falls back to using the page title in the absence of metadata', function () {
            for (var name in tags) {
                tags[name].remove();
            }
            metadata = doc.getDocumentMetadata();
            assert.strictEqual(metadata.title, document.title);
        });
    });

    describe('absoluteUrl()', function () {
        it('should add the protocol when the url starts with two slashes', function () {
            var result = doc.absoluteUrl('//example.com/');
            assert.equal(result, 'http://example.com/');
        });

        it('should add a trailing slash when given an empty path', function () {
            var result = doc.absoluteUrl('http://example.com');
            assert.equal(result, 'http://example.com/');
        });

        it('should make a relative path into an absolute url', function () {
            var result = doc.absoluteUrl('path');
            var expected = document.location.protocol + '//' + document.location.host + document.location.pathname.replace(/[^\/]+$/, '') + 'path';
            assert.equal(result, expected);
        });

        it('should make an absolute path into an absolute url', function () {
            var expected, result;
            result = doc.absoluteUrl('/path');
            expected = document.location.protocol + '//' + document.location.host + '/path';
            assert.equal(result, expected);
        });
    });
});
