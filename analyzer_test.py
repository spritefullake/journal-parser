import unittest
from analyzer import *
from functools import reduce
from itertools import chain

class TestAnalyzer(unittest.TestCase):
    journal_file = "out/Journal.json"
    def test_unique_authors_same_count(self):
        data = read_in_json(journal_file)
        total_count = len(data)
        by_author = collect_unique(data,"author")
        flat = list(chain(*by_author.values()))
        assert len(flat) == total_count
    def test_punctuation_filtered(self):
        assert filter_punctuation("french’apostrophe's, and other @# marks !~ are wiped") == list("frenchapostrophes and other  marks  are wiped")
        assert filter_punctuation("he're is some. punc!.tuation") == list("here is some punctuation")

if __name__ == '__main__':
    unittest.main()