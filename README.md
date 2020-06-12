# Wikipedia Search Engine

A scalable cloud-based search engine for Wikipedia.

This is a basic web-application that was built with performance and scalability in mind.

Tasked with developing a search engine for a cloud computing module, I decided to produce a search engine for Wikipedia.

No longer in deployment (out of credits).

## Deployment

Each component/service below was containerised with **Docker**.

The containers were orchestrated with **Docker-Compose** during development.

Originally deployed as **EC2** and **RDS** instances on **Amazon Web Services** with **Terraform**, I found **Google Cloud Platform** simpler for my purposes.

In production, the containers were orchestrated by **Google Kubernetes Engine** and monitored by **Stackdriver** (now Operations) on GCP.

## Components

### Spider / Crawler

- Built with **Python** and the **Scrapy** framework
- Follows best practices by obeying the robots.txt file and limiting the
  number of requests
- Instances of this Spider node can be run in parallel without data duplication
- The spider avoids scraping previously parsed URLs but considers them in the random trail selection for each spider node
- Extracts page and image URLs as well as titles, headings and content

### Indexer

- Part of the spider middleware
- Processes page content by removing stop words and punctuation
- The 20 most common words in each page are stored for the inverted index

### Database

- **PostgreSQL** database
- Contains tables for pages, ads and keywords
- Currently contains data scripts, but can be started without being populated

### Search User Interface

- Built with **Node** and **Express**
- Connects to the database with environment variables so that connection settings can be established from the dockerfile
- Simple algorithm returns the top 30 pages that have their ID listed in the inverted index for each of the search words
- The page results are simply sorted by how many of the search words match the page's keywords
- The component only reads from the database and is completely stateless so as to support multiple search instances running at once, allowing for simultaneous searches at a large scale

![User Interface](https://github.com/Inaki-McKearney/Wikipedia-Search-Engine/blob/master/screenshots/UI.png?raw=true)
