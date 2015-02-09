FROM rocker/shiny:latest
RUN rm -rf /srv/shiny-server
COPY shiny-server.conf /etc/shiny-server/
COPY ./app /srv/app
EXPOSE 5000
