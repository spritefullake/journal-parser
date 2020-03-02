use lib 'lib';
use Journal;
use Journal::Output;

sub MAIN(Str $input = "Journal.txt", Str $output = "Journal.html"){
    my $result = Journal::Journal.parsefile($input , :enc("UTF-8"),
    :actions(Journal::Output::Journal-to-html.new));
    my $str = $result.made<entries>.Str;
    $output.IO.spurt: $str;
    time-taken();
}
sub time-taken(){
    say "Time taken: " ~ (now - INIT now) ~ "ms";
}