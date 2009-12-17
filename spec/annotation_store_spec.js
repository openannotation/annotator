describe('AnnotationStore', function () {
    before_each(function () {
        el = $('<div></div>')[0];
        a = new AnnotationStore({}, el);
    });

    it('has no annotations when first loaded', function () {
        expect(a.annotations).to(be_empty);
    });

    it('should save an annotation on an annotationCreated event', function () {
        expect(a.annotations).should(eql, []);
        mock_request().and_return('', 'text/plain');
        expect(a).should(receive, 'annotationCreated', 'once').with_args(null, 'annotation1');
        // Trigger annotationCreated event for 'annotation1';
        $(el).trigger('annotationCreated', ['annotation1']);        
        expect(a.annotations).should(eql, ['annotation1']);
    });
    
    it('should remove an annotation on an annotationDeleted event', function () {
        // Add one annotation
        a.registerAnnotation('annotation1');
        expect(a.annotations).should(eql, ['annotation1']);
        // Respond positively to the request to delete.
        mock_request().and_return('', 'text/plain');
        // Check the annotationDeleted method is called.
        expect(a).should(receive, 'annotationDeleted', 'once').with_args(null, 'annotation1');
        // Trigger annotationDeleted event for 'annotation1'. 
        $(el).trigger('annotationDeleted', ['annotation1']);
        // Make sure annotation is no longer in the registry.
        expect(a.annotations).should(eql, []);
    });

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
