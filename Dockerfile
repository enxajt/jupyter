FROM jupyter/datascience-notebook
USER root

RUN apt-get update && apt-get install -y \
  language-pack-ja-base \
  language-pack-ja \
  ibus-mozc \
  fonts-ipafont-gothic \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
RUN update-locale LANG=ja_JP.UTF-8 LANGUAGE=ja_JP:ja
ENV LC_ALL C.UTF-8

RUN apt-get update && apt-get install -y \
  fonts-takao
