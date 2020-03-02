unit module Journal;

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
role Journal-actions is export {
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
sub sayHi() is export {
    say "HI this is journla";
}