# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: https://docs.scrapy.org/en/latest/topics/item-pipeline.html
import psycopg2

class SpiderPipeline(object):
    # def process_item(self, item, spider):
    #     return item
    
    def open_spider(self, spider):

        self.connection = psycopg2.connect(database="wikidata", user="inaki", password="password", host="database", port="5432")
        self.cur = self.connection.cursor()

    def close_spider(self, spider):
        self.cur.close()
        self.connection.close()

    def process_item(self, item, spider):
        self.cur.execute("INSERT INTO pages VALUES(%s,%s,default,%s,%s)",(item['pageID'],item['uri'],item['title'],item['image']))
        print("Added:", item["title"])
        for word in item['words']:
            self.cur.execute(f"SELECT EXISTS(SELECT 1 FROM words WHERE word='{word}')")
            if not self.cur.fetchone()[0]: # new word
                self.cur.execute(f"INSERT INTO words (word, page_ids) VALUES ('{word}', '{{{item['pageID']}}}');")
            else:
                self.cur.execute(f"""UPDATE words
                                SET word = '{word}',
                                page_ids = page_ids || '{{{item['pageID']}}}'
                                WHERE word = '{word}';""")

        # self.cur.execute
        self.connection.commit()
        return item


# cur.execute("""
# with dupe_removed as (
# 	select word, ARRAY(SELECT DISTINCT UNNEST(page_ids)) as values from words
# 	) 
# update words set page_ids = dr.values
# from dupe_removed dr
# where dr.word = words.word;
# select * from words""")
# con.commit()
# con.close()