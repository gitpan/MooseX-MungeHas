=pod

=encoding utf-8

=head1 PURPOSE

Test that MooseX::MungeHas features work with Mouse.

=head1 DEPENDENCIES

Test requires Mouse 1.00 or is skipped.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2013 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use strict;
use warnings;
use Test::Requires { "Mouse" => "1.00" };
use Test::More;

use Types::Standard -types;

my $Even = Int->create_child_type(
	name       => "Even",
	constraint => sub { $_ % 2 == 0 },
)->plus_coercions(Int, '2 * $_');

{
	package Local::Class1;
	use Mouse;
	use MooseX::MungeHas qw( is_ro simple_isa always_coerce );
	has attr1 => (isa => $Even, coerce => 1);
	has attr2 => (isa => $Even, coerce => 0); # this should be simplified to Int
	has attr3 => (isa => $Even, is => "rwp");
	has attr4 => (isa => $Even, is => "lazy", default => sub { 42 });
}

ok(
	Local::Class1->meta->get_attribute("attr$_")->should_coerce,
	qq[Local::Class1->meta->get_attribute("attr$_")->should_coerce],
) for 1, 3, 4;

ok(
	!Local::Class1->meta->get_attribute("attr2")->should_coerce,
	q[not Local::Class1->meta->get_attribute("attr2")->should_coerce],
);

ok(
	Local::Class1->meta->get_attribute("attr$_")->type_constraint == $Even,
	qq[Local::Class1->meta->get_attribute("attr$_")->type_constraint == \$Even],
) || diag(Local::Class1->meta->get_attribute("attr1")->type_constraint) for 1, 3, 4;

ok(
	Local::Class1->meta->get_attribute("attr2")->type_constraint == Int,
	q[Local::Class1->meta->get_attribute("attr2")->type_constraint == Int],
) or diag(Local::Class1->meta->get_attribute("attr2")->type_constraint);

can_ok("Local::Class1", "_set_attr3");

my $o = Local::Class1->new;
ok(
	!exists $o->{attr4},
	'$o->attr4 is not initialized',
);
is(
	$o->attr4,
	42,
	'default worked',
);
ok(
	exists $o->{attr4},
	'$o->attr4 is now initialized',
);

done_testing;
