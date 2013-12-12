Registry = require('../../src/registry')


describe 'Registry', ->
  s = {}
  r = null
  m = null

  beforeEach ->
    s = {}
    r = new Registry(s)

    m =
      configure: sinon.spy((registry) -> registry['foo'] = 'bar')
      run: sinon.stub()

  it 'should take a settings Object as its first constructor argument', ->
    assert.equal(r.settings, s)

  describe '#include()', ->

    it 'should invoke the configure method of the passed module with itself', ->
      r.include(m)
      assert(m.configure.calledWith(r))

  describe '#run()', ->

    it 'should include the application module', ->
      sinon.spy(r, 'include')
      r.run(m)
      assert(r.include.calledWith(m))

    it 'should extend the application with registry extensions', ->
      r.run(m)
      assert.equal(m['foo'], 'bar')

    it 'should invoke the run method fo the passed module with itself', ->
      r.run(m)
      assert(m.run.calledWith(r))
