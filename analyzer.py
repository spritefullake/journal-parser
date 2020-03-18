import nltk # type: ignore
import json
import re
import string
from typing import List, Dict, Tuple
from itertools import islice, combinations
from functools import partial, reduce
import matplotlib.pyplot as plt # type: ignore

from nltk.classify import NaiveBayesClassifier # type: ignore
from nltk.corpus import subjectivity # type: ignore
from nltk.sentiment import SentimentAnalyzer # type: ignore
from nltk.sentiment.vader import SentimentIntensityAnalyzer # type: ignore
from nltk.sentiment.util import * # type: ignore

wnl = nltk.WordNetLemmatizer()
journal_file = "out/Journal.json"
analyzed_path = "out/Analyzed_Journal.json"

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

def analyze_by_author(entries : List[Dict]) -> Tuple[str, str]:
    get_content = partial(map, lambda entry : entry["content"])
    pipeline_per_author = lambda entries : "\n".join(get_content(entries)) # type: ignore
    
    uniques = collect_unique(entries, "author")
    authors = uniques.keys()
    entries = uniques.values()
    return zip(authors, map(pipeline_per_author, entries))

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
    return [token for token in tokens if re.search(f"[^{string.punctuation}’]", token)]

def author_conditional_frequency(entries_by_author):
    pronouns = ["i","me","you","us","he","she","him","her","they","them"]
    return nltk.ConditionalFreqDist(
        (author, word)
        for author, entry in entries_by_author
        for word in nltk.word_tokenize(entry.lower())
        if word in pronouns
    )

def to_percent(count, tokens):
    return count / len(set(tokens)) * 100

def get_frequencies(tokens, start=0, sample_size=5):
    
    frequencies = nltk.FreqDist(tokens)
    sliced = frequencies.most_common()[start : start + sample_size % len(frequencies)]
    return [(word, to_percent(frequency, tokens)) for word, frequency in sliced]

def plot_frequencies(frequent_words, word_frequencies):
    plt.plot(frequent_words, word_frequencies)


entries = read_in_json(journal_file)
entries_by_author = list(analyze_by_author(entries))
map(lambda entry : enhance_entry(entry, entry["content"]), entries)
author_conditional_frequency(entries_by_author)
for author, aggregate in entries_by_author:
    tokens = filter_punctuation(nltk.word_tokenize(aggregate))

    frequencies = get_frequencies(tokens, 0, 100)
    # zip(*list_of_tuples) actually unzips 
    plot_list = map(list, zip(*frequencies))
    plot_frequencies(*plot_list)
    
    normalized_frequences = [(token, to_percent(count, tokens)) for token, count in frequencies[:10]]
    print(normalized_frequences)
plt.show()

with open(analyzed_path,"w") as output:
    output.write(json.dumps(entries))
