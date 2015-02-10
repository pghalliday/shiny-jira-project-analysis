FROM rocker/shiny:latest
RUN rm -rf /srv/shiny-server
COPY shiny-server.conf /etc/shiny-server/
COPY ./R /srv/R
RUN R -e "install.packages(c('tm', 'wordcloud', 'memoise'), repos='http://cran.rstudio.com/')"
EXPOSE 5000
