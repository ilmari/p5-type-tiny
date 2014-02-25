=pod

=encoding utf-8

=head1 PURPOSE

Tests the situation where we create a type C<X> with a coercion;
then create a type C<< ArrayRef[X] >>; then alter the coercion for
C<X>. C<< ArrayRef[X] >> should reflect that change.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2014 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use strict;
use warnings;
use lib qw( ./lib ./t/lib ../inc ./inc );

use Test::More;
use Test::Fatal;

use Types::Standard qw( ArrayRef Int HashRef RegexpRef );

my $X = Int->create_child_type;
$X->coercion->add_type_coercions(HashRef, q[42]);

is(
	$X->coerce({}),
	42,
	'$X->coerce({})',
);

my $Xes  = ArrayRef[$X];

is_deeply(
	$Xes->coerce([4,{},2]),
	[4,42,2],
	'$Xes->coerce([4,{},2])',
);

$X->coercion->add_type_coercions(RegexpRef, q[99]);

is(
	$X->coerce({}),
	42,
	'$X->coerce({})',
);

is(
	$X->coerce(qr//),
	99,
	'$X->coerce(qr//)',
);

{
	local $TODO = "still not working";
	is_deeply(
		$Xes->coerce([4,{},2,qr//,1]),
		[4,42,2,99,1],
		'$Xes->coerce([4,{},2,qr//,1])',
	);
}

done_testing;
