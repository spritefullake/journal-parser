grammar Journal {
    token TOP {
        $<header> = [.*?]
        <sig>+ %% $<content> = [.*?] # match entries as delimiters
	    $<content> = [.+] # match the last content
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
    method TOP ($/) {
        # different ways of using hyper
        my @contents = $<content>
            .hyper
            .grep(not * ~~ '');
        my @sigs = $<sig>;
	my @entries = (zip(@sigs>>{'author', 'date'}, @contents)).race.map: (-> 
	(($author, $date), $content) { 
		%(author => $author.Str, date => $date.Str, content => $content.Str) 
	});
        make {
            entries => @entries
        }
    }

}
my $path := "Journal.txt";
my $result = Journal.parsefile($path, :enc("UTF-8"),
:actions(Journal-actions.new));
$result.made<entries>.say;
say "Time taken: " ~ (now - INIT now) ~ "ms";
