import nltk # type: ignore
import json
import re
from typing import List, Dict
from itertools import islice
from functools import partial, reduce
import matplotlib.pyplot as plt # type: ignore

from nltk.classify import NaiveBayesClassifier # type: ignore
from nltk.corpus import subjectivity # type: ignore
from nltk.sentiment import SentimentAnalyzer # type: ignore
from nltk.sentiment.vader import SentimentIntensityAnalyzer # type: ignore
from nltk.sentiment.util import * # type: ignore

wnl = nltk.WordNetLemmatizer()

def tokens_then_text(input : str):
    tokens = nltk.word_tokenize(input)
    return nltk.Text(tokens)

def collect_by(key, acc, item):
    if item[key] not in acc:
        acc[item[key]] = [item]
    else:
        acc[item[key]].append(item)

    return acc

def collect_unique(entries : List[Dict], key) -> Dict:
    collect_by_key = partial(collect_by, key)
    return reduce(collect_by_key, entries, {})

def analyze_by_author(entries : List[Dict]):
    get_content = partial(map, lambda entry : entry["content"])
    pipeline_per_author = lambda entries : "\n".join(get_content(entries)) # type: ignore
    
    uniques = collect_unique(entries, "author").values()
    return map(pipeline_per_author, uniques)

def read_in_json(filename : str):
    try:
        with open(filename,"r") as journal:
            return json.load(journal)
    except IOError:
        print("Could not read the file ",filename)

def enhance_entry(entry : Dict, content : str) -> Dict:
    # Add nltk stats, scores and breakdowns to the entry
    tokens = nltk.word_tokenize(content)
    lemmatized = [wnl.lemmatize(token) for token in tokens]
    sentences = nltk.sent_tokenize(content)
    sid = SentimentIntensityAnalyzer()
    sentiment_score = sid.polarity_scores(content)

    entry["sentences"] = sentences
    entry["tokens"] = tokens
    entry["word_density"] = len(tokens) / len(sentences)
    entry["lemmatized"] = lemmatized
    entry["sentiment_score"] = sentiment_score

    return entry

def filter_punctuation(tokens):
    # Remove punctuation from a token
    return [token for token in tokens if re.search("[^.,''`?!’]",token)]

journal_file = "Journal.json"
entries = read_in_json(journal_file)
entries_by_author = analyze_by_author(entries)

map(lambda entry : enhance_entry(entry, entry["content"]), entries)

for aggregate in entries_by_author:
    tokens = filter_punctuation(nltk.word_tokenize(aggregate))

    to_percent = lambda count : count / len(set(tokens)) * 100
    frequencies = nltk.FreqDist(tokens)
    start_from = 0
    sample_size = 10
    sliced = frequencies.most_common()[start_from : start_from + sample_size % len(frequencies)]
    frequent_words = [word for word, _ in sliced]
    word_frequencies = [to_percent(frequency) for _, frequency in sliced]
    plt.plot(frequent_words, word_frequencies)
    plt.figure(1)
    
    normalized_frequences = [(token, to_percent(count)) for token, count in frequencies.most_common(10)]
    print(normalized_frequences)
plt.show()

with open("Analyzed_Journal.json","w") as output:
    output.write(json.dumps(entries))
