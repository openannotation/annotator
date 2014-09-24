h = require('helpers')
Range = require('xpath-range').Range

UI = require('../../../src/ui')
Util = require('../../../src/util')

$ = Util.$

testDocument = """
  <div>
    <p>Hello world!</p>
    <p>Giraffes like leaves.</p>
    <ul>
      <li>First item</li>
      <li>Second item</li>
    </ul>
  </div>
"""

testData = [
  {
    name: 'single element inner'
    annotations: [{
      ranges: [{
        start: '/p[1]'
        startOffset: 0
        end: '/p[1]'
        endOffset: 12
      }]
    }]
    highlights: [
      [0, 'Hello world!']
    ]
  }
  {
    name: 'single element subset'
    annotations: [{
      ranges: [{
        start: '/p[2]'
        startOffset: 9
        end: '/p[2]'
        endOffset: 13
      }]
    }]
    highlights: [
      [0, 'like']
    ]
  }
  {
    name: 'spanning element boundaries'
    annotations: [{
      ranges: [{
        start: '/p[1]'
        startOffset: 6
        end: '/p[2]'
        endOffset: 8
      }]
    }]
    highlights: [
      [0, 'world!']
      [0, 'Giraffes']
    ]
  }
  {
    name: 'spanning multiple elements'
    annotations: [{
      ranges: [{
        start: '/p[1]'
        startOffset: 6
        end: '/ul/li[1]'
        endOffset: 5
      }]
    }]
    highlights: [
      [0, 'world!']
      [0, 'Giraffes like leaves.']
      [0, 'First']
    ]
  }
  {
    name: 'multiple overlapping annotations'
    annotations: [
      {
        ranges: [{
          start: '/p[2]'
          startOffset: 0
          end: '/p[2]'
          endOffset: 13
        }]
      }
      {
        ranges: [{
          start: '/p[2]'
          startOffset: 9
          end: '/p[2]'
          endOffset: 21
        }]
      }
    ]
    highlights: [
      [0, 'Giraffes like']
      [1, 'like']
      [1, ' leaves.']
    ]
  }
  {
    name: 'multiple overlapping annotations spanning elements'
    annotations: [
      {
        ranges: [{
          start: '/p[1]'
          startOffset: 6
          end: '/ul/li[1]'
          endOffset: 5
        }]
      }
      {
        ranges: [{
          start: '/ul[1]/li[1]'
          startOffset: 0
          end: '/ul/li[2]'
          endOffset: 11
        }]
      }
    ]
    highlights: [
      [0, 'world!']
      [0, 'Giraffes like leaves.']
      [0, 'First']
      [1, 'First']
      [1, ' item']
      [1, 'Second item']
    ]
  }
]


describe 'UI.Highlighter', ->
  elem = null
  hl = null

  beforeEach ->
    elem = $(testDocument).get(0)
    hl = new UI.Highlighter(elem)

  afterEach ->
    hl.destroy()


  describe '.draw(annotation)', ->
    ann = null

    beforeEach ->
      ann = {
        id: 'abc123'
        ranges: [{
          start: '/p[1]'
          startOffset: 0
          end: '/p[1]'
          endOffset: 12
        }]
      }

    afterEach ->
      # If we have stubbed this during the test, reset it.
      Range.sniff.restore?()

    it "should return drawn highlights", ->
      highlights = hl.draw(ann)

      assert.equal(highlights.length, 1)
      assert.equal($(highlights[0]).text(), 'Hello world!')

    it "should draw highlights in the hl's element", ->
      hl.draw(ann)

      highlights = $(elem).find('.annotator-hl')

      assert.equal(highlights.length, 1)
      assert.equal(highlights.text(), 'Hello world!')

    it "should set the `annotation` data property of each highlight
        element to be a reference to the annotation", ->
      highlights = hl.draw(ann)

      assert.equal(highlights.length, 1)
      assert.equal($(highlights[0]).data('annotation'), ann)

    it "should set a `data-annotation-id` data attribute on each highlight
        with the annotations id, if it has one", ->
      highlights = hl.draw(ann)

      assert.equal(highlights.length, 1)
      assert.equal($(highlights[0]).attr('data-annotation-id'), ann.id)

    it "should swallow errors if the annotation fails to normalize", ->
      e = new Range.RangeError("typ", "RangeError should have been caught!")
      sinon.stub(Range, 'sniff').returns({
        normalize: sinon.stub().throws(e)
      })
      hl.draw({
        id: 123
        ranges: [{fake: 'range'}]
      })


  describe '.undraw(annotation)', ->
    ann = null

    beforeEach ->
      ann = {
        id: 'abc123'
        ranges: [{
          start: '/p[1]'
          startOffset: 0
          end: '/p[1]'
          endOffset: 12
        }]
      }
      hl.draw(ann)

    it "should remove any highlights stored on the annotation", ->
      hl.undraw(ann)
      highlights = $(elem).find('.annotator-hl')
      assert.equal(highlights.length, 0)


  describe '.redraw(annotation)', ->
    ann = null

    beforeEach ->
      ann = {
        id: 'abc123'
        ranges: [{
          start: '/p[1]'
          startOffset: 0
          end: '/p[1]'
          endOffset: 12
        }]
      }
      hl.draw(ann)

    it "should redraw any drawn highlights", ->
      ann.id = 'elephants'
      hl.redraw(ann)
      highlights = $(elem).find('.annotator-hl')
      assert.equal(highlights.length, 1)
      assert.equal($(highlights[0]).attr('data-annotation-id'), 'elephants')

    it "should return the list of new highlight elements", ->
      ann.id = 'elephants'
      highlights = hl.redraw(ann)
      assert.equal($(highlights[0]).attr('data-annotation-id'), 'elephants')


  describe '.drawAll(annotations)', ->
    anns = null

    beforeEach ->
      anns = [
        {
          id: 'abc123'
          ranges: [{
            start: '/p[1]'
            startOffset: 0
            end: '/p[1]'
            endOffset: 12
          }]
        }
        {
          id: 'def456'
          ranges: [{
            start: '/p[2]'
            startOffset: 0
            end: '/p[2]'
            endOffset: 20
          }]
        }
      ]

    it "should draw highlights in the hl's element for each annotation in
        annotations", ->
      hl.drawAll(anns)

      highlights = $(elem).find('.annotator-hl')

      assert.equal(highlights.length, 2)
      assert.equal(highlights.eq(0).text(), 'Hello world!')
      assert.equal(highlights.eq(1).text(), 'Giraffes like leaves')

    it "should return a promise that resolves to the list of drawn
       highlights", (done) ->
      hl.drawAll(anns)
      .then (highlights) ->
        assert.equal(highlights.length, 2)
        assert.equal($(highlights[0]).text(), 'Hello world!')
        assert.equal($(highlights[1]).text(), 'Giraffes like leaves')
      .then(done, done)

    it "should draw highlights in chunks of @options.chunkSize at a time,
        pausing for @options.chunkDelay between draws", ->
      clock = sinon.useFakeTimers()
      sinon.stub(hl, 'draw')

      hl.options.chunkSize = 7
      hl.options.chunkDelay = 42

      annotations = [{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}]

      hl.drawAll(annotations)
      assert.equal(hl.draw.callCount, 7)
      clock.tick(42)
      assert.equal(hl.draw.callCount, 13)

      clock.restore()
      hl.draw.restore()

  describe '.destroy()', ->

    it "should remove any drawn highlights", ->
      ann = {
        id: 'abc123'
        ranges: [{
          start: '/p[1]'
          startOffset: 0
          end: '/p[1]'
          endOffset: 12
        }]
      }
      hl.draw(ann)
      hl.destroy()
      assert.equal($(elem).find('.annotator-hl').length, 0)

  # A helper function which returns a generated test case (a function)
  testFromData = (event, i) ->
    ->
      annotations = testData[i].annotations
      expectedHighlights = testData[i].highlights

      # Draw the request annotations
      actualHighlights = []
      for ann in annotations
        actualHighlights = actualHighlights.concat(hl.draw(ann))

      # First, a sanity check. Did we create the same number of highlights as we
      # expected.
      assert.equal(actualHighlights.length, expectedHighlights.length,
                  "Didn't create the correct number of highlights")

      # Step through the created annotations, checking their textual content
      # against the values provided in testData.
      expectedHighlights.forEach (hl, index) ->
        [annId, hlText] = hl
        actualHl = actualHighlights[index]
        # Check the highlight is a pointer to the right annotation
        assert.equal(
          $(actualHl).data('annotation'),
          annotations[annId],
          "`annotation` data field doesn't point to correct annotation"
        )
        # Check the highlight text is correct
        assert.equal($(actualHl).text(), hlText)

  for i in [0...testData.length]
    it "should draw highlights correctly for test case #{i}
        (#{testData[i].name})", testFromData('annotationCreated', i)
