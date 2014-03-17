package Type::Coercion::_Paramd;

use 5.006001;
use strict;
use warnings;

BEGIN {
	$Type::Coercion::_Paramd::AUTHORITY = 'cpan:TOBYINK';
	$Type::Coercion::_Paramd::VERSION   = '0.040';
}

sub new
{
	my $class    = shift;
	my @partials = @_;
	bless \@partials, $class;
}

use overload '+' => 'add';

sub add
{
	my ($self, $other, $swap) = @_;
	
	return $self->complete(
		$other,
		$swap ? 'plus_coercions' : 'plus_fallback_coercions',
	) if $other->isa('Type::Tiny');
	
	my @self  = @$self;
	my @other = $other->isa(__PACKAGE__) ? @$other : $other;
	return ref($self)->new(
		$swap ? (@other, @self) : (@self, @other)
	);
}

sub complete
{
	my $self = shift;
	my ($type, $method) = @_;
	
	my @coercions = map {
		if (ref($_) eq q(ARRAY)) {
			my ($coderef, @params) = @$_;
			$self->$coderef($type, @params);
		}
		else {
			@{ $_->type_coercion_map }
		}
	} @$self;
	
	$type->$method(@coercions);
	$type;
}

1;
