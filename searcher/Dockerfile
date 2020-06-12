FROM node:8.16.2-alpine3.9

WORKDIR /usr/src/app

COPY package.json ./

RUN npm install --only=prod

COPY . .

EXPOSE 8080

ENV PGUSER inaki
ENV PGHOST database
ENV PGPASSWORD password
ENV PGDATABASE wikidata
ENV PGPORT 5432

CMD [ "npm", "run", "start" ]
