describe ('jquery.i18n plugin', function() {
  
	it ('translates a key into the string', function() {
		$.i18n.load({ a_key: 'translated string' });
		
		expect($.i18n._('a_key')).toEqual('translated string');
	});
	
	it ('returns the key when there is no translation', function() {
		$.i18n.load({ a_key: 'translated string' });
		
		expect($.i18n._('another_key')).toEqual('another_key');
	});
	
	describe ('variable substitution', function() {
	  
		describe ('variable lists', function() {
		  
			it ('allows a string variable to be substituted into a translation', function() {
				$.i18n.load({ a_key: 'translated string %s' });

				expect($.i18n._('a_key', ['variable'])).toEqual('translated string variable');
			});
		
			it ('allows many string variable to be substituted into a translation', function() {
				$.i18n.load({ a_key: 'translated string %s - %s - %s' });

				expect($.i18n._('a_key', ['variables', 'in', 'list'])).toEqual('translated string variables - in - list');
			});
		
			it ('handles variables at the start of a translation', function() {
				$.i18n.load({ a_key: '%s and %s' });

				expect($.i18n._('a_key', ['string 1', 'string 2'])).toEqual('string 1 and string 2');
			});
		
			it ('treats %%s as a literal %s', function() {
				$.i18n.load({ a_key: '%s and a literal %%s and %s' });

				expect($.i18n._('a_key', ['string 1', 'string 2'])).toEqual('string 1 and a literal %s and string 2');
			});
			
		});
		
		describe ('numbered variables', function() {
			
			it ('put 2 numbered variables out of order', function() {
				$.i18n.load({ a_key: 'translated string %2$s - %1$s' });

				expect($.i18n._('a_key', ['order', 'in'])).toEqual('translated string in - order');
			});
			
			it ('put 2 numbered variables in order', function() {
				$.i18n.load({ a_key: 'translated string %1$s - %2$s' });

				expect($.i18n._('a_key', ['order', 'in'])).toEqual('translated string order - in');
			});
		
			it ('put many numbered variables in random order', function() {
				$.i18n.load({ a_key: 'translated string %3$s %1$s - %2$s' });

				expect($.i18n._('a_key', ['in', 'order',  'many' ])).toEqual('translated string many in - order');
			});
			
		});
		
	});
	
});
