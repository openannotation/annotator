describe('AnnotationStore', function () {
    before_each(function () {
        el = $('<div></div>')[0];
        a = new AnnotationStore({}, el);
    });

    it('has no annotations when first loaded', function () {
        expect(a.annotations).to(be_empty);
    });

    it('should save the annotation on an annotationCreated event', function () {
        mock_request().and_return('OK', 'text/plain');
        // with_args with 'null' conveniently skips the check for that 
        // argument. Here we don't check the event object.
        expect(a).should(receive, 'annotationCreated', 'once').with_args(null, 'annotator', 'annotation', ['annotationElementsList']);
        // this is the same event that Annotator triggers when an annotation 
        // is created.
        $(el).trigger('annotationCreated', ['annotator', 'annotation', ['annotationElementsList']]);
    });

    // it('adds a serialized description of the selection to its registry on createAnnotation', function () {
    //     stub(window, 'getSelection').and_return(testSelection(0));
    //     a.checkForSelection();
    //     a.createAnnotation();
    //     expect(a.annotations).to(have_length, 1);
    //     expect(a.annotations[0].ranges).to(eql, [{
    //         start: "/p/strong",
    //         startOffset: 13,
    //         end: "/p/strong",
    //         endOffset: 27
    //     }]);
    // });

    it('should generate RESTful URLs by default', function () {
      expect(a._urlFor('create')).should(eql, '/store/annotations');
      expect(a._urlFor('read', 'foo')).should(eql, '/store/annotations/foo');
      expect(a._urlFor('update', 'bar')).should(eql, '/store/annotations/bar');
      expect(a._urlFor('destroy', 'baz')).should(eql, '/store/annotations/baz');
    });

    it('should generate URLs as specified by its options otherwise', function () {
      a.options.prefix = '/some/prefix/';
      a.options.urls.create = 'createMe';
      a.options.urls.read = ':id/readMe';
      a.options.urls.update = ':id/updateMe';
      a.options.urls.destroy = ':id/destroyMe';
      expect(a._urlFor('create')).should(eql, '/some/prefix/createMe');
      expect(a._urlFor('read', 'foo')).should(eql, '/some/prefix/foo/readMe');
      expect(a._urlFor('update', 'bar')).should(eql, '/some/prefix/bar/updateMe');
      expect(a._urlFor('destroy', 'baz')).should(eql, '/some/prefix/baz/destroyMe');
    });
});
