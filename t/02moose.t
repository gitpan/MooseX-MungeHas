use strict;
use warnings;
use Test::Requires { "Moose" => "2.0000" };
use Test::More;

use Types::Standard -types;

my $Even = Int->create_child_type(
	name       => "Even",
	constraint => sub { $_ % 2 == 0 },
)->plus_coercions(Int, '2 * $_');

{
	package Local::Class1;
	use Moose;
	use MooseX::MungeHas qw( is_ro simple_isa always_coerce );
	has attr1 => (isa => $Even, coerce => 1);
	has attr2 => (isa => $Even, coerce => 0); # this should be simplified
	has attr3 => (isa => $Even, is => "rwp");
}

ok(
	Local::Class1->meta->get_attribute("attr1")->should_coerce,
	q[Local::Class1->meta->get_attribute("attr1")->should_coerce],
);

ok(
	!Local::Class1->meta->get_attribute("attr2")->should_coerce,
	q[not Local::Class1->meta->get_attribute("attr2")->should_coerce],
);

ok(
	Local::Class1->meta->get_attribute("attr3")->should_coerce,
	q[Local::Class1->meta->get_attribute("attr3")->should_coerce],
);

ok(
	Local::Class1->meta->get_attribute("attr1")->type_constraint == $Even,
	q[Local::Class1->meta->get_attribute("attr1")->type_constraint == $Even],
) or diag Local::Class1->meta->get_attribute("attr1")->type_constraint;

ok(
	Local::Class1->meta->get_attribute("attr2")->type_constraint == Int,
	q[Local::Class1->meta->get_attribute("attr2")->type_constraint == Int],
) or diag Local::Class1->meta->get_attribute("attr2")->type_constraint;

ok(
	Local::Class1->meta->get_attribute("attr3")->type_constraint == $Even,
	q[Local::Class1->meta->get_attribute("attr3")->type_constraint == $Even],
) or diag Local::Class1->meta->get_attribute("attr3")->type_constraint;

can_ok("Local::Class1", "_set_attr3");

done_testing;
