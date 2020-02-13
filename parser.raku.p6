grammar Journal {
    # it is important to keep your top level
    # capture restricted to one token or 
    # else your match object will match
    # everything it gets between () instead of
    # just the token you desire
    token TOP {
        #[.+?] 
        #($<entry> = [.*]? % <sig>) [.+]
        #(<sig>  $<entry> = [.*?]  <?before <sig>>)+? .*
        #(<entry>+)  
        #[.*]
        #(<entry>)+ % ','
        #(','<entry>)+

        $<header> = [.*?]
        <sig>+ %% $<entry> = [.*?] # match entries as delimiters
        $<entry> = [.+] # match the last entry
    } 
    #[.+?] <entry>+ 
    token date { (<digit>+)<sep>(<digit>+)<sep>(<digit>+) }
    token sep { '/' | '-' | <ws> }
    token sig { <date>" - "<author> }
    token author { \w+ }

}

class Journal-actions{
    # two ways to get unique authors
    # The OO style
    has Str @!authors;
    # The functional style
    sub unique-authors (@entries) {
        @entries>>.&(-> 
            $entry { $entry<sig><author>.Str }
        )
        .unique
    }
    method TOP ($/) {
        my @entries = $<entry>;
        make {
            entries => @entries,
            #signatures => @entries>>.&(-> $entry { $entry<sig>}),
            authors => @!authors.unique
            #dates => $<date>
        }
    }
    method author ($/) {
        @!authors.push($/.Str);
    }
}
my $path := "Journal.txt";
my $result = Journal.parsefile($path, :enc("UTF-8"),
:actions(Journal-actions.new));
#$result.made<entries>[0].say;
$result.made.say;
$result.made<entries>.elems.say;
#$result.made<entries>.elems.Str ~ " Is how many" ==> say();