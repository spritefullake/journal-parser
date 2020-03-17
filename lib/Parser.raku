use lib 'lib';
use Journal;
use Journal::Output;

my %choices = :html(Journal::Output::Journal-to-html), :json(Journal::Output::Journal-to-JSON);

sub MAIN(Str $input = "Journal.txt", Str $output-name = "Journal", List $output-formats = <html json>){
    my @results = %choices{$output-formats.List}:p.race.map: -> $pair {
        my $result := Journal::Journal.parsefile($input , :enc("UTF-8"), :actions($pair.value.new));
        my $filename := $output-name ~ "." ~ $pair.key;
        $filename.IO.spurt: $result.made<entries>.Str;
    }
    time-taken();
}

sub time-taken(){
    say "Time taken: " ~ (now - INIT now) ~ "ms";
}