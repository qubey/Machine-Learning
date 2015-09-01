from html.parser import HTMLParser
from pylab import *
import sys
import nltk

WORD_TYPES = ['JJR', 'JJS', 'IN', 'JJ', 'NN', 'NNPS', 'NNS', 'RB', 'RBR', 'RBS', 'RP', 'VB', 'VBD', 'VBG', 'VBN', 'VBP', 'VBZ']

class HtmlPageTokenizer(HTMLParser):
  def __init__(self):
    HTMLParser.__init__(self)
    self.data = []
    self.link_urls = []
    self.final_data = None
    self.in_script = False

  ##
  # Right now we are only saving all of the hrefs from links
  ##
  def handle_starttag(self, tag, attrs):
    if tag == 'script':
      in_script = True

    if tag != 'a':
      return

    if 'href' not in attrs:
      return

    self.link_urls.append(attrs['href'])

  def handle_endtag(self, tag):
    if tag == 'script':
      in_script = False

  ##
  # Store all of the text data
  ##
  def handle_data(self, data):
    if self.in_script == False:
      self.data.append(data)

  def get_data(self):
    if self.final_data is not None:
      return self.final_data

    all_text = ' '.join(self.data)
    tokens = nltk.tokenize.word_tokenize(all_text)

    tagged_tokens = nltk.pos_tag(tokens)
    words = [w.lower() for w,wtype in tagged_tokens if wtype in WORD_TYPES]

    stemmer = nltk.stem.snowball.SnowballStemmer("english")
    self.final_data = [stemmer.stem(word) for word in words]

    return self.final_data
    

content = open(sys.argv[1], 'r', encoding='utf-8').read()
tokenizer = HtmlPageTokenizer()
tokenizer.feed(content)


outfile = open('temp.log', 'w', encoding='utf-8')
outfile.write('\n'.join(tokenizer.get_data()))
outfile.close()
