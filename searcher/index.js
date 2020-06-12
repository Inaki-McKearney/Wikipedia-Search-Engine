const express = require('express');
const exphbs = require('express-handlebars');
const { Pool } = require('pg');

const pool = new Pool();

const app = express();

const PORT = process.env.PORT || '8080';

app.engine(
  'handlebars',
  exphbs({
    defaultLayout: 'main',
  })
);

app.set('view engine', 'handlebars');

app.get('/', async (req, res) => {
  var hits = [];
  var results = [];
  var ad = {
    content: 'YOUR AD HERE',
    uri: 'https://www.your-ad-here.co.uk',
  };

  if (!req.query.q || !req.query.q.trim()) {
    res.render('index', {
      ad: ad,
      results: results,
    });
    console.log('cancelled');
    return;
  }

  var queries = req.query.q.toLowerCase().split(' ');
  var itemsProcessed = 0;

  var ad = await getAD(queries);

  queries.forEach(function (q) {
    pool.query(
      `select unnest(page_ids) page from words where word like '${q}'`,
      (err, res) => {
        if (err) {
          console.log(err.stack);
        } else {
          for (i of res.rows) {
            sasdsasdsasd;
            page = i['page'].toString();
            hits[page] = hits[page] ? hits[page] + 1 : 1;
          }
          itemsProcessed++;
          if (itemsProcessed === queries.length) {
            getTopResults(ad);
          }
        }
      }
    );
  });

  function getTopResults(ad) {
    var pageHits = [];
    var resultCount = 0;
    var pageIDs = [];

    for (var hit in hits) {
      if (resultCount > 29) break;
      resultCount += 1;
      pageHits.push([hit, hits[hit]]);
    }

    pageHits.sort(function (a, b) {
      return b[1] - a[1];
    });

    for (i in pageHits) {
      pageIDs.push(pageHits[i][0]);
    }

    pool.query(
      `SELECT uri, title FROM pages WHERE id = ANY ('{${pageIDs}}'::int[])`,
      (err, response) => {
        if (err) {
          console.log(err.stack);
        } else {
          res.render('index', {
            ad: ad,
            results: response.rows,
          });
        }
      }
    );
  }
});

app.listen(PORT, () => {
  console.log(`Listening to requests on port: ${PORT}`);
});

function getAD(keywords) {
  return new Promise((resolve, _) => {
    var selectQuery = `SELECT content, uri FROM ads, UNNEST(keywords) k WHERE LOWER(k) LIKE '%${keywords[0]}%'`;
    for (var i = 1; i < keywords.length; i++) {
      selectQuery += ` OR LOWER(k) LIKE '%${keywords[i]}%'`;
    }
    selectQuery += ' ORDER BY random() LIMIT 1;';

    pool.query(selectQuery, (err, res) => {
      if (err) {
        console.log(err.stack);
        resolve({
          content: 'Ad Not Found',
          uri: '#',
        });
      } else {
        if (res.rows[0] == null) {
          pool.query(
            'select content, uri from ads order by random() limit 1',
            (err, res) => {
              if (err) {
                console.log(err.stack);
                resolve({
                  content: 'Ad Not Found',
                  uri: '#',
                });
              } else {
                resolve(res.rows[0]);
              }
            }
          );
        } else {
          resolve(res.rows[0]);
        }
      }
    });
  });
}

// pool.end()
