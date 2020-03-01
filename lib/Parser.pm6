unit module Parser;
use YAMLish;
use Typesafe::HTML;
use Typesafe::XHTML::Writer :ALL;

grammar Journal {
    token TOP {
        $<header> = .*?  
        <entry>+           # match multiple entries in sequence     
        || <FAILGOAL>      # finally fail if nothing else matches
    }
    regex entry { <sig><content> }
    token sig { <date>" - "<author> } # each entry has a signature
    token author { \w+ }
    token date { (<digit>+)<sep>(<digit>+)<sep>(<digit>+) }
    token sep { '/' | '-' | <ws> }
    #keep content as a regex to preserve its backtracking
    regex content { 
        (.+?)
        [
            <?sig> 
            || $ 
            # the last chunk of content will run to the end of the line 
            # which is why the $ is important to keep
        ] 
    } 

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
    method entry($/){
        # <entry> only gets matched as much as <content>
        # while <sig> gets matched almost twice that amount
        @!authors.push($/<sig><author>.Str);
        @!dates.push($/<sig><date>.Str);
        @!contents.push($/<content>.Str);
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
}
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