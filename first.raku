# My first try using Raku programming langauge! (it's 1:28am rn)
# https://perl6advent.wordpress.com/2017/12/02/ 
# Make immutable variables with := 
my $name := "karen";
say $name;
# For mutable assignment, use = instead
my $grade = "A+";
$grade = "D-"; # :/

# The $ sigil wraps values in a 'scalar' container when used with the =
# assignment operator, which can only hold one value 
# scalar containers are kind of like auto-dereferencing pointers that avoid flattening
my $scalar = 12;
# holding a list as one scalar instead of 3 values
my $still_scalar = (1,2,3); 
# note that a list binds its items as values directly instead of wrapping
# each item within a scalar container
# lists are also immutable by default
my $bound_values := (5,6,7);
# Similarly, @ wraps values in an 'array' container
# which can hold multiple values
# arrays wrap each item inside a scalar container
# (technically it specifies the Positional type-constraint, which allows for lists
# and arrays to be values of a variable)
my @pets := "cat", "fish";
# each item of a @ or % sigilled variable is wrapped in a scalar container
my @hobbies = ("running", "jumping", "flying"), %(:19age, :100friends);
# Sigil-less variables take the form \x and implement the is raw trait in parameters
my \not_so_fancy = 12;

# The hyper >> operator applies a function to all items in a container 
my @nums = 1...40;
sub quad($x --> Int:D) {
  $x**2 + 2*$x + 2
}
# The & symbol provides a function handle (lets us grab onto the function instead
# of calling it) while the . applies the function as if it were a method(?) 
say @nums>>.&quad;

