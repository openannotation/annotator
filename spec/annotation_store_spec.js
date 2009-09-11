describe('AnnotationStore', function () {
    before_each(function () {
        el = $('<div></div>')[0];
        a = new AnnotationStore({}, el);
    });

    it('should save the annotation on an annotationCreated event', function () {
        mock_request().and_return('OK', 'text/plain');
        // with_args with 'null' conveniently skips the check for that 
        // argument. Here we don't check the event object.
        expect(a).should(receive, 'createAnnotation', 'once').with_args(null, 'annotator', 'annotation');
        // this is the same event that Annotator triggers when an annotation 
        // is created.
        $(el).trigger('annotationCreated', ['annotator', 'annotation']);
    });

    it('should generate RESTful URLs by default', function () {
      expect(a._urlFor('create')).should(eql, '/store/annotation');
      expect(a._urlFor('read', 'foo')).should(eql, '/store/annotation/foo');
      expect(a._urlFor('update', 'bar')).should(eql, '/store/annotation/bar');
      expect(a._urlFor('destroy', 'baz')).should(eql, '/store/annotation/baz');
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
