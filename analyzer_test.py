import unittest
from analyzer import *
from functools import reduce
from itertools import chain

class TestAnalyzer(unittest.TestCase):
    journal_file = "Journal.json"
    def test_unique_authors_same_count(self):
        data = read_in_json("Journal.json")
        total_count = len(data)
        by_author = collect_unique(data,"author")
        flat = list(chain(*by_author.values()))
        assert len(flat) == total_count

if __name__ == '__main__':
    unittest.main()