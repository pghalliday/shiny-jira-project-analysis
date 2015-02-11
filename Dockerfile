FROM rocker/shiny:latest
RUN rm -rf /srv/shiny-server
COPY shiny-server.conf /etc/shiny-server/
COPY ./R /srv/R
EXPOSE 5000
