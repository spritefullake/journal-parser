use Test;
use lib <lib>;
use Parser;
ok True, "This is a test";

my Str $input = "Journal.txt";
my Str $output = "Journal.html";
my $result = Parser::Journal.parsefile($input , :enc("UTF-8"),
:actions(Parser::Journal-to-html.new));
my $str = $result.made<entries>.Str;
$output.IO.spurt: $str;
ok .&{
    my $count = $result<entry>.elems;
    "Count is $count \n".say;
    $count == 86
}, "Ensure last entry gets counted!";




done-testing();