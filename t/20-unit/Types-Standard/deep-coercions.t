=pod

=encoding utf-8

=head1 PURPOSE

If a coercion exists for type C<Foo>, then Type::Tiny should be able to
auto-generate a coercion for type C<< ArrayRef[Foo] >>, etc.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2013-2014 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use strict;
use warnings;
use lib qw( ./lib ./t/lib ../inc ./inc );

use Test::More;

use Types::Standard qw( -types slurpy );
use Type::Utils;

NONINLINED: {
	my $Foo = declare Foo => as Int;
	coerce $Foo, from Num, via { int($_) };
	$Foo->coercion->freeze;
	
	my $ArrayOfFoo = declare ArrayOfFoo => as ArrayRef[$Foo], coercion => 1;
	
	ok($ArrayOfFoo->has_coercion, '$ArrayOfFoo has coercion');
	
	my $arr1 = [1..3];
	my $arr2 = [1..3, "Hello"];
	
	is(
		$ArrayOfFoo->coerce($arr1),
		$arr1,
		'$ArrayOfFoo does not coerce value that needs no coercion',
	);
	
	is_deeply(
		$ArrayOfFoo->coerce([1.1, 2.1, 3.1]),
		[1, 2, 3],
		'$ArrayOfFoo does coerce value that can be coerced',
	);
	
	is(
		$ArrayOfFoo->coerce($arr2),
		$arr2,
		'$ArrayOfFoo does not coerce value that cannot be coerced',
	);
	
	my $HashOfFoo = HashRef[$Foo];
	
	ok($HashOfFoo->has_coercion, '$HashOfFoo has coercion');
	
	my $hsh1 = {one => 1, two => 2, three => 3};
	my $hsh2 = {one => 1, two => 2, three => 3, greeting => "Hello"};
	
	is(
		$HashOfFoo->coerce($hsh1),
		$hsh1,
		'$HashOfFoo does not coerce value that needs no coercion',
	);
	
	is_deeply(
		$HashOfFoo->coerce({one => 1.1, two => 2.2, three => 3.3}),
		{one => 1, two => 2, three => 3},
		'$HashOfFoo does coerce value that can be coerced',
	);
	
	is(
		$HashOfFoo->coerce($hsh2),
		$hsh2,
		'$HashOfFoo does not coerce value that cannot be coerced',
	);
	
	my $RefOfFoo = ScalarRef[$Foo];
	ok($RefOfFoo->has_coercion, '$RefOfFoo has coercion');
	
	my $ref1 = do { my $x = 1; \$x };
	my $ref2 = do { my $x = "xxx"; \$x };
	
	is(
		$RefOfFoo->coerce($ref1),
		$ref1,
		'$RefOfFoo does not coerce value that needs no coercion',
	);
	
	is_deeply(
		${ $RefOfFoo->coerce(do { my $x = 1.1; \$x }) },
		1,
		'$RefOfFoo does coerce value that can be coerced',
	);
	
	is(
		$RefOfFoo->coerce($ref2),
		$ref2,
		'$RefOfFoo does not coerce value that cannot be coerced',
	);
	
	# This added coercion should be ignored, because undef shouldn't
	# need coercion!
	my $MaybeFoo = Maybe[$Foo->plus_coercions(Undef, 999)];
	
	is(
		$MaybeFoo->coerce(undef),
		undef,
		'$MaybeFoo does not coerce undef',
	);
	
	is(
		$MaybeFoo->coerce(42),
		42,
		'$MaybeFoo does not coerce integer',
	);
	
	is(
		$MaybeFoo->coerce(4.2),
		4,
		'$MaybeFoo does coerce non-integer number',
	);
	
	is(
		$MaybeFoo->coerce("xyz"),
		"xyz",
		'$MaybeFoo cannot coerce non-number',
	);
};

INLINED: {
	my $Bar = declare Bar => as Int;
	coerce $Bar, from Num, q { int($_) };
	$Bar->coercion->freeze;
	
	my $ArrayOfBar = ArrayRef[$Bar];
	$ArrayOfBar->coercion->freeze;
	
	ok($ArrayOfBar->has_coercion, '$ArrayOfBar has coercion');
	ok($ArrayOfBar->coercion->can_be_inlined, '$ArrayOfBar coercion can be inlined');
	
	my $arr1 = [1..3];
	my $arr2 = [1..3, "Hello"];
	
	is(
		$ArrayOfBar->coerce($arr1),
		$arr1,
		'$ArrayOfBar does not coerce value that needs no coercion',
	);
	
	is_deeply(
		$ArrayOfBar->coerce([1.1, 2.1, 3.1]),
		[1, 2, 3],
		'$ArrayOfBar does coerce value that can be coerced',
	);
	
	is(
		$ArrayOfBar->coerce($arr2),
		$arr2,
		'$ArrayOfBar does not coerce value that cannot be coerced',
	);
	
	my $HashOfBar = HashRef[$Bar];
	$HashOfBar->coercion->freeze;
	
	ok($HashOfBar->has_coercion, '$HashOfBar has coercion');
	ok($HashOfBar->coercion->can_be_inlined, '$HashOfBar coercion can be inlined');
	
	my $hsh1 = {one => 1, two => 2, three => 3};
	my $hsh2 = {one => 1, two => 2, three => 3, greeting => "Hello"};
	
	is(
		$HashOfBar->coerce($hsh1),
		$hsh1,
		'$HashOfBar does not coerce value that needs no coercion',
	);
	
	is_deeply(
		$HashOfBar->coerce({one => 1.1, two => 2.2, three => 3.3}),
		{one => 1, two => 2, three => 3},
		'$HashOfBar does coerce value that can be coerced',
	);
	
	is(
		$HashOfBar->coerce($hsh2),
		$hsh2,
		'$HashOfBar does not coerce value that cannot be coerced',
	);
	
	my $RefOfBar = ScalarRef[$Bar];
	$RefOfBar->coercion->freeze;
	
	ok($RefOfBar->has_coercion, '$RefOfBar has coercion');
	ok($RefOfBar->coercion->can_be_inlined, '$RefOfBar coercion can be inlined');
	
	my $ref1 = do { my $x = 1; \$x };
	my $ref2 = do { my $x = "xxx"; \$x };
	
	is(
		$RefOfBar->coerce($ref1),
		$ref1,
		'$RefOfBar does not coerce value that needs no coercion',
	);
	
	is_deeply(
		${ $RefOfBar->coerce(do { my $x = 1.1; \$x }) },
		1,
		'$RefOfBar does coerce value that can be coerced',
	);
	
	is(
		$RefOfBar->coerce($ref2),
		$ref2,
		'$RefOfBar does not coerce value that cannot be coerced',
	);
	
	# This added coercion should be ignored, because undef shouldn't
	# need coercion!
	my $MaybeBar = Maybe[$Bar->plus_coercions(Undef, 999)];
	
	is(
		$MaybeBar->coerce(undef),
		undef,
		'$MaybeBar does not coerce undef',
	);
	
	is(
		$MaybeBar->coerce(42),
		42,
		'$MaybeBar does not coerce integer',
	);
	
	is(
		$MaybeBar->coerce(4.2),
		4,
		'$MaybeBar does coerce non-integer number',
	);
	
	is(
		$MaybeBar->coerce("xyz"),
		"xyz",
		'$MaybeBar cannot coerce non-number',
	);
};

MAP: {
	my $IntFromStr = declare IntFromStr => as Int;
	coerce $IntFromStr, from Str, q{ length($_) };
	
	my $IntFromNum = declare IntFromNum => as Int;
	coerce $IntFromNum, from Num, q{ int($_) };
	
	my $IntFromArray = declare IntFromArray => as Int;
	coerce $IntFromArray, from ArrayRef, via { scalar(@$_) };
	
	$_->coercion->freeze for $IntFromStr, $IntFromNum, $IntFromArray;
	
	my $Map1 = Map[$IntFromNum, $IntFromStr];
	$Map1->coercion->freeze;
	
	ok(
		$Map1->has_coercion && $Map1->coercion->can_be_inlined,
		"$Map1 has an inlinable coercion",
	);
	is_deeply(
		$Map1->coerce({ 1.1 => "Hello", 2.1 => "World", 3.1 => "Hiya" }),
		{ 1 => 5, 2 => 5, 3 => 4 },
		"Coercions to $Map1",
	);
	is_deeply(
		$Map1->coerce({ 1.1 => "Hello", 2.1 => "World", 3.1 => [] }),
		{ 1.1 => "Hello", 2.1 => "World", 3.1 => [] },
		"Impossible coercion to $Map1",
	);
	my $m = { 1 => 2 };
	is(
		$Map1->coerce($m),
		$m,
		"Unneeded coercion to $Map1",
	);
	
	my $Map2 = Map[$IntFromNum, $IntFromArray];
	ok(
		$Map2->has_coercion && !$Map2->coercion->can_be_inlined,
		"$Map2 has a coercion, but it cannot be inlined",
	);
	is_deeply(
		$Map2->coerce({ 1.1 => [1], 2.1 => [1,2], 3.1 => [] }),
		{ 1 => 1, 2 => 2, 3 => 0 },
		"Coercions to $Map2",
	);
	is_deeply(
		$Map2->coerce({ 1.1 => [1], 2.1 => [1,2], 3.1 => {} }),
		{ 1.1 => [1], 2.1 => [1,2], 3.1 => {} },
		"Impossible coercion to $Map2",
	);
	$m = { 1 => 2 };
	is(
		$Map2->coerce($m),
		$m,
		"Unneeded coercion to $Map2",
	);
};

DICT: {
	my $IntFromStr = declare IntFromStr => as Int;
	coerce $IntFromStr, from Str, q{ length($_) };
	
	my $IntFromNum = declare IntFromNum => as Int;
	coerce $IntFromNum, from Num, q{ int($_) };

	my $IntFromArray = declare IntFromArray => as Int;
	coerce $IntFromArray, from ArrayRef, via { scalar(@$_) };
	
	$_->coercion->freeze for $IntFromStr, $IntFromNum, $IntFromArray;
	
	my $Dict1 = Dict[ a => $IntFromStr, b => $IntFromNum, c => Optional[$IntFromNum] ];
	$Dict1->coercion->freeze;
	
	{
		local $TODO = "By new only-inline-when-frozen rules, strictly this should not be inlined.";
		ok(
			$Dict1->has_coercion && $Dict1->coercion->can_be_inlined,
			"$Dict1 has an inlinable coercion",
		);
	}
	
	is_deeply(
		$Dict1->coerce({ a => "Hello", b => 1.1, c => 2.2 }),
		{ a => 5, b => 1, c => 2 },
		"Coercion (A) to $Dict1",
	);
	is_deeply(
		$Dict1->coerce({ a => "Hello", b => 1 }),
		{ a => 5, b => 1 },
		"Coercion (B) to $Dict1",
	);
	is_deeply(
		$Dict1->coerce({ a => "Hello", b => 1, c => [], d => 1 }),
		{ a => "Hello", b => 1, c => [], d => 1 },
		"Coercion (C) to $Dict1 - changed in 0.003_11; the presence of an additional value cancels coercion",
	);
};

DICT_PLUS_SLURPY: {
	my $Rounded1 = Int->plus_coercions(Num, q[int($_)]);
	my $Dict1    = Dict[ a => $Rounded1, slurpy Map[$Rounded1, $Rounded1] ];
	
	is_deeply(
		$Dict1->coerce({ a => 1.1, 2.2 => 3.3, 4.4 => 5 }),
		{ a => 1, 2 => 3, 4 => 5 },
		"Coercion to $Dict1 (inlined)",
	);
	
	my $Rounded2 = Int->plus_coercions(Num, sub { int($_) });
	my $Dict2    = Dict[ a => $Rounded2, slurpy Map[$Rounded2, $Rounded2] ];
	
	is_deeply(
		$Dict2->coerce({ a => 1.1, 2.2 => 3.3, 4.4 => 5 }),
		{ a => 1, 2 => 3, 4 => 5 },
		"Coercion to $Dict2 (non-inlined)",
	);
};

TUPLE: {
	my $IntFromStr = declare IntFromStr => as Int;
	coerce $IntFromStr, from Str, q{ length($_) };
	
	my $IntFromNum = declare IntFromNum => as Int;
	coerce $IntFromNum, from Num, q{ int($_) };
	
	my $IntFromArray = declare IntFromArray => as Int;
	coerce $IntFromArray, from ArrayRef, via { scalar(@$_) };
	
	$_->coercion->freeze for $IntFromStr, $IntFromNum, $IntFromArray;
	
	my $Tuple1 = Tuple[ $IntFromNum, Optional[$IntFromStr], slurpy ArrayRef[$IntFromNum]];
	$Tuple1->coercion->freeze;
	
	{
		local $TODO = "By new only-inline-when-frozen rules, strictly this should not be inlined.";
		ok(
			$Tuple1->has_coercion && $Tuple1->coercion->can_be_inlined,
			"$Tuple1 has an inlinable coercion",
		);
	}
	
	is_deeply(
		$Tuple1->coerce([qw( 1.1 1.1 )]),
		[1, 3],
		"Coercion (A) to $Tuple1",
	);
	is_deeply(
		$Tuple1->coerce([qw( 1.1 1.1 2.2 2.2 33 3.3 )]),
		[1, 3, 2, 2, 33, 3],
		"Coercion (B) to $Tuple1",
	);
	
	my $Tuple2 = Tuple[ $IntFromNum ];
	is_deeply(
		$Tuple2->coerce([qw( 1.1 )]),
		[ 1 ],
		"Coercion (A) to $Tuple2",
	);
	
	is_deeply(
		$Tuple2->coerce([qw( 1.1 2.2 )]),
		[ 1.1, 2.2 ],
		"Coercion (B) to $Tuple2 - changed in 0.003_11; the presence of an additional value cancels coercion",
	);
};

done_testing;
