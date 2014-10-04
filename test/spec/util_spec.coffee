h = require('helpers')
Util = require('../../src/util')
$ = Util.$

describe 'Util.escapeHtml()', ->
  it "escapes tag special characters", ->
    assert.equal(Util.escapeHtml('/<>'), '&#47;&lt;&gt;')

  it "escapes attribute special characters", ->
    assert.equal(Util.escapeHtml("'" + '"'), '&#39;&quot;')

  it "escapes entity special characters", ->
    assert.equal(Util.escapeHtml('&'), '&amp;')

  it "escapes entity special characters strictly", ->
    assert.equal(Util.escapeHtml('&amp;'), '&amp;amp;')
