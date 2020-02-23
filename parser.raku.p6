grammar Journal {
    token TOP {
        $<header> = [.*?]
        <sig> ~ (<sig>)? $<content> = [.*?] # match entries as delimiters
	    $<content> = [.+] # match the last content
        || <FAILGOAL> # finally fail if nothing else matches
    } 
    token date { (<digit>+)<sep>(<digit>+)<sep>(<digit>+) }
    token sep { '/' | '-' | <ws> }
    token sig { <date>" - "<author> }
    token author { \w+ }
    method FAILGOAL($goal){
    	die "Failed on the goal $goal at position {self.pos}";
    }
}
class Journal-actions{
    has @!dates;
    has @!authors;
    my Str $empty := '';

    method TOP ($/) {
        my @contents = $<content>.grep(not * ~~ $empty)>>.Str;

        my @entries = 
            (@!authors Z @!dates Z @contents).race.map(-> 
            ($author, $date, $content) { 
                %(author => $author, date => $date, content => $content) 
            });
        make {
            entries => @entries
        }
    }
    method date($/){
	    @!dates.push($/.Str)
    }
    method author($/){
	    @!authors.push($/.Str)
    }
}
my $path := "Journal.txt";
my $result = Journal.parsefile($path, :enc("UTF-8"),
:actions(Journal-actions.new));
$result.made<entries>.say;
say "Time taken: " ~ (now - INIT now) ~ "ms";
