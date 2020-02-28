use YAMLish;
use Typesafe::HTML;
use Typesafe::XHTML::Writer :ALL;
grammar Journal {
    token TOP {
        $<header> = .*?  
        (<sig><content>)+
        $<footer> = .*            
        || <FAILGOAL>      # finally fail if nothing else matches
    }
    token date { (<digit>+)<sep>(<digit>+)<sep>(<digit>+) }
    token sep { '/' | '-' | <ws> }
    token sig { <date>" - "<author> }
    token author { \w+ }

    #keep content as a regex to preserve its backtracking
    regex content { (.+?)[<?sig>] } 

    method FAILGOAL($goal){
    	die "Failed on the goal $goal at position {self.pos}";
    }
}
role Journal-actions{
    has Str @.dates;
    has Str @.authors;
    has Str @.contents;
    my Str $empty := '';
    method TOP ($/) {...}
    method date($/){
	    @!dates.push($/.Str)
    }
    method author($/){
	    @!authors.push($/.Str)
    }
    method content($/){
        @!contents.push($/.Str)
    }
}
class Journal-to-hash does Journal-actions {
    method TOP ($/) {
        my @entries = 
            (@!authors Z @!dates Z @!contents).hyper.map: -> 
            ($author, $date, $content) { 
                %(author => $author, date => $date, content => $content) 
            };
        make {
            entries => @entries
        }
    }
}
class Journal-to-html does Journal-actions {
    method TOP ($/) {
        my $entries = 
            html (@!authors Z @!dates Z @!contents).hyper.map: &to-html;

        make {
            entries => $entries
        }
    }
}

sub to-html(($author, $date, $content is rw)) {
    # convert newlines to linebreaks for html
    $content ~~ s:g|"\n"|<br>|;
    my $content-with-linebreaks := div.new($content);
    div(
        h1("By $author on $date"),
        $content-with-linebreaks
    )
};

sub MAIN(Str $input = "Journal.txt", Str $output = "Journal.html"){
    my $result = Journal.parsefile($input , :enc("UTF-8"),
    :actions(Journal-to-html.new));
    my $str = $result.made<entries>.Str;
   
    $output.IO.spurt: $str;

    time-taken();
}

sub time-taken(){
    say "Time taken: " ~ (now - INIT now) ~ "ms";
}