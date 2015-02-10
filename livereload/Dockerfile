FROM node
RUN mkdir -p /watch
COPY livereload.js /watch/
WORKDIR /watch
RUN npm install livereload
EXPOSE 35729
CMD node livereload.js
