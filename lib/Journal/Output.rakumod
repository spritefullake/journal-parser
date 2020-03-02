use YAMLish;
use Typesafe::HTML;
use Typesafe::XHTML::Writer :ALL;
use Journal;

module Journal::Output {
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