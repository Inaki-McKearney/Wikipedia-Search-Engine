import scrapy
import string
from nltk.corpus import stopwords
import nltk
import time
import datetime
import psycopg2
from spider.items import SpiderItem
from collections import Counter 


# database connection
con = psycopg2.connect(database="wikidata", user="inaki", password="password", host="database", port="5432")
cur = con.cursor()

nltk.download("stopwords")
stops = set([x.replace("'","") for x in stopwords.words("english")]+['wikipedia','parser','output', 'cs1','retreived','edit'])
punctuation = string.punctuation+'·•'

cur.execute("SELECT uri FROM pages;")
parsed_urls = set([element for (element,) in cur.fetchall()])

cur.execute("SELECT MAX(id) FROM pages;")
maxID = cur.fetchone()[0]
nextID = maxID+1 if maxID else 1
print('Writing to page id:', nextID)


def cleanText(dirtyText):
    text = [x for x in dirtyText if len(x) > 2]
    text = ' '.join(text).lower()
    text = text.translate(str.maketrans(punctuation, ' ' * len(punctuation)))
    text = text.split()
    text = [x for x in text if len(x) > 2 and x not in stops]

    return text


class WikiSpider(scrapy.Spider):
    name = "wikipedia"

    allowed_domains = ['en.wikipedia.org']

    start_urls = [
        'https://en.wikipedia.org/wiki/Main_Page'
        'https://en.wikipedia.org/wiki/Cloud_computing',
        'https://en.wikipedia.org/wiki/Queen%27s_University_Belfast',
        'https://en.wikipedia.org/wiki/Animal'
    ] + list(parsed_urls)

    def parse(self, response):
        print(response.url)
        a_selectors = response.xpath('//div[@class="mw-body-content"]//a')
        for selector in a_selectors:
            link = selector.xpath("@href").extract_first()
            if (link is not None):
                yield response.follow(link, self.textParse)
                yield response.follow(link, self.parse)

    def textParse(self, response):
        if response.url in parsed_urls:
            return

        cur.execute(f"SELECT EXISTS(SELECT 1 FROM pages WHERE uri='{response.url}')")
        if cur.fetchone()[0]:
            return

        global nextID

        title = response.xpath('//title/text()').get()

        if title[-12:] == ' - Wikipedia':
            title = title[:-12].replace("'","")

        image = response.xpath('//meta[@property="og:image"]/@content').get()
        if image and len(image) > 499:
            image = None

        sel = response.xpath('//body//div[@class="mw-body"][1]//div[@class="mw-body-content"][1]')

        content = sel.xpath("/descendant-or-self::*[not(self::script)]/text()").extract()

        keywords = [x[0] for x in Counter(cleanText(content)).most_common(20)] + title.split()
        
        nextID += 1
    

        yield SpiderItem(
            pageID = nextID - 1,
            uri = response.url,
            title = title,
            image = image,

            words = keywords
        )


        # text = ' '.join(map(str.strip,sel.xpath("/descendant-or-self::*[not(self::script)]/text()").extract())).translate(str.maketrans(punctuation, ' '*len(punctuation))).lower()
        # filtered_text = [word for word in text.split() if (word not in stops and len(word)>2)]


        # yield SpiderItem(
        #     uri=response.url,
        #     timestamp=datetime.datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S'),
        #     title = title,
        #     content=' '.join(filtered_text),
        #     image = image          
        # )


# cur.close()
