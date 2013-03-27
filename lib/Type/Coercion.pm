package Type::Coercion;

use 5.008001;
use strict;
use warnings;

BEGIN {
	$Type::Coercion::AUTHORITY = 'cpan:TOBYINK';
	$Type::Coercion::VERSION   = '0.001';
}

use Scalar::Util qw< blessed >;

sub _confess ($;@)
{
	require Carp;
	@_ = sprintf($_[0], @_[1..$#_]) if @_ > 1;
	goto \&Carp::confess;
}

use overload
	q(&{})     => sub { my $t = shift; sub { $t->coerce(@_) } },
	fallback   => 1,
;
use if ($] >= 5.010001), overload =>
	q(~~)      => sub { $_[0]->has_coercion_for_value($_[1]) },
;

sub new
{
	my $class  = shift;
	my %params = (@_==1) ? %{$_[0]} : @_;	
	my $self   = bless \%params, $class;
	return $self;
}

sub type_constraint   { $_[0]{type_constraint} }
sub type_coercion_map { $_[0]{type_coercion_map} ||= [] }

sub coerce
{
	...;
}

sub assert_coerce
{
	...;
}

sub has_coercion_for_type
{
	...;
}

sub has_coercion_for_value
{
	...;
}

sub add_type_coercions
{
	my $self = shift;
	my @args = @_;
	
	while (@args)
	{
		my $type     = shift @args;
		my $coercion = shift @args;
		
		_confess "types must be blessed Type::Tiny objects"
			unless blessed($type) && $type->isa("Type::Tiny");
		_confess "coercions must be code references"
			unless ref($coercion);  # really want: does($coercion, "&{}")
		
		push @{$self->type_coercion_map}, $type, $coercion;
	}
	
	return $self;
}

1;