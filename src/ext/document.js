"use strict";

var annotator = require('annotator');

var util = annotator.util;
var $ = util.$;

// isEmpty returns a boolean indicating whether the passed object is empty
function isEmpty(obj) {
    // null and undefined objects are empty
    if (typeof obj === 'undefined' || obj === null) {
        return true;
    }

    for (var k in obj) {
        if (obj.hasOwnProperty(k)) {
            return false;
        }
    }

    return true;
}


// absoluteUrl turns a possibly relative URL into an absolute one
function absoluteUrl(url) {
    var d = global.document.createElement('a');
    d.href = url;
    return d.href;
}


function getMetaTags(prefix, attribute, delimiter) {
    var tags = {},
        matchRe = new RegExp("^" + prefix + delimiter + "(.+)$", "i");

    $("meta").each(function (_, meta) {
        var name = $(meta).attr(attribute),
            content = $(meta).prop("content");
        if (name) {
            var match = name.match(matchRe);
            if (match) {
                var n = match[1];
                if (tags[n]) {
                    tags[n].push(content);
                } else {
                    tags[n] = [content];
                }
            }
        }
    });
    return tags;
}


function getHighwire() {
    return getMetaTags("citation", "name", "_");
}


function getFacebook() {
    return getMetaTags("og", "property", ":");
}


function getTwitter() {
    return getMetaTags("twitter", "name", ":");
}


function getDublinCore() {
    return getMetaTags("dc", "name", ".");
}


function getPrism() {
    return getMetaTags("prism", "name", ".");
}


function getEprints() {
    return getMetaTags("eprints", "name", ".");
}


function getFavicon() {
    var result = null;
    $("link").each(function (_, link) {
        var rel = $(link).prop("rel");
        if (rel === "shortcut icon" || rel === "icon") {
            result = absoluteUrl(link.href);
            return;
        }
    });
    return result;
}


function getTitle(d, keys) {
    for (var i = 0, len = keys.length; i < len; i++) {
        var k = keys[i];
        if (!d.hasOwnProperty(k)) {
            continue;
        }
        if (!d[k].hasOwnProperty('title')) {
            continue;
        }
        if (d[k].title.length === 0) {
            continue;
        }
        return d[k].title[0];
    }

    // Fall back to document title
    return global.document.title;
}


function getLinks() {
    // we know our current location is a link for the document
    var results = [{href: global.document.location.href}];

    // look for some relevant link relations
    $("link").each(function (_, link) {
        var $l = $(link),
            rel = $l.prop('rel');

        if (!(rel === "alternate" ||
              rel === "canonical" ||
              rel === "shortlink" ||
              rel === "bookmark")) {
            return;
        }

        var type = $l.prop('type'),
            lang = $l.prop('hreflang');

        if (rel === 'alternate') {
            // Ignore feeds resources
            if (type && type.match(/^application\/(rss|atom)\+xml/)) { return; }
            // Ignore alternate languages
            if (lang) { return; }
        }

        // get absolute url
        var href = absoluteUrl($l.prop('href'));

        results.push({href: href, rel: rel, type: type});
    });

    return results;
}


function getHighwireLinks(meta) {
    var i,
        len,
        results = [];

    // kind of a hack to express DOI identifiers as links but it's a
    // convenient place to look them up later, and somewhat sane since
    // they don't have a type
    var dois = meta.doi;
    if (typeof dois !== 'undefined' && dois !== null) {
        for (i = 0, len = dois.length; i < len; i++) {
            var doi = dois[i];
            if (doi.slice(0, 4) !== "doi:") {
                doi = "doi:" + doi;
            }
            results.push({href: doi});
        }
    }

    // look for links in scholar metadata
    // jscs:disable requireCamelCaseOrUpperCaseIdentifiers
    var urls = meta.pdf_url;
    // jscs:enable requireCamelCaseOrUpperCaseIdentifiers
    if (typeof urls !== 'undefined' && urls !== null) {
        for (i = 0, len = urls.length; i < len; i++) {
            results.push({
                href: absoluteUrl(urls[i]),
                type: "application/pdf"
            });
        }
    }

    return results;
}


function getDublinCoreLinks(meta) {
    var results = [];

    // look for links in dublincore data
    var ident = meta.identifier;
    if (typeof ident !== 'undefined' && ident !== null) {
        for (var i = 0, len = ident.length; i < len; i++) {
            if (ident[i].slice(0, 4) === 'doi:') {
                results.push({href: ident[i]});
            }
        }
    }

    return results;
}


var METADATA_FIELDS = {
    dc: getDublinCore,
    eprints: getEprints,
    facebook: getFacebook,
    highwire: getHighwire,
    prism: getPrism,
    twitter: getTwitter
};


var METADATA_TITLE_ORDER = [
    'highwire',
    'eprints',
    'prism',
    'facebook',
    'twitter',
    'dc'
];


function getDocumentMetadata() {
    var out = {};

    // first look for some common metadata types
    // TODO: look for microdata/rdfa?
    for (var name in METADATA_FIELDS) {
        var result = METADATA_FIELDS[name]();
        if (!isEmpty(result)) {
            out[name] = result;
        }
    }

    var favicon = getFavicon();
    if (favicon) {
        out.favicon = favicon;
    }

    // extract out/normalize some things
    out.title = getTitle(out, METADATA_TITLE_ORDER);

    var link = getLinks();
    if ('highwire' in out) {
        link = link.concat(getHighwireLinks(out.highwire));
    }
    if ('dc' in out) {
        link = link.concat(getDublinCoreLinks(out.dc));
    }
    if (link.length > 0) {
        out.link = link;
    }

    return out;
}


var doc = function () {
    var metadata = getDocumentMetadata();

    return {
        beforeAnnotationCreated: function (ann) {
            // Assign a copy of the document metadata to the annotation
            ann.document = JSON.parse(JSON.stringify(metadata));
        }
    };
};

annotator.ext.document = doc;

exports.document = doc;
exports.absoluteUrl = absoluteUrl;
exports.getDocumentMetadata = getDocumentMetadata;
