# CentOS Application Docker (Application Container)
[![Build Status](https://travis-ci.org/zeroc0d3lab/centos-application.svg?branch=master)](https://travis-ci.org/zeroc0d3lab/centos-application) [![](https://images.microbadger.com/badges/image/zeroc0d3lab/centos-application:latest.svg)](https://microbadger.com/images/zeroc0d3lab/centos-application:latest "Layers") [![](https://images.microbadger.com/badges/version/zeroc0d3lab/centos-application:latest.svg)](https://microbadger.com/images/zeroc0d3lab/centos-application:latest "Version") [![GitHub issues](https://img.shields.io/github/issues/zeroc0d3lab/centos-application.svg)](https://github.com/zeroc0d3lab/centos-application/issues) [![GitHub forks](https://img.shields.io/github/forks/zeroc0d3lab/centos-application.svg)](https://github.com/zeroc0d3lab/centos-application/network) [![GitHub stars](https://img.shields.io/github/stars/zeroc0d3lab/centos-application.svg)](https://github.com/zeroc0d3lab/centos-application/stargazers) [![GitHub license](https://img.shields.io/badge/license-GPLv2-blue.svg)](https://raw.githubusercontent.com/zeroc0d3lab/centos-application/master/LICENSE.GPL)

This docker image includes:

## Features:
* bash (+ themes)
* oh-my-zsh (+ themes)
* tmux (+ themes)
* vim (+ plugins with vundle & themes)
* rbenv / rvm
  - [X] gem test unit (rspec, serverspec)
  - [X] gem docker-api
  - [X] gem sqlite3, mongoid, sequel, apktools
  - [X] gem mysql2 (run: yum install -y mysql-devel)
  - [X] gem pg, sequel_pg (run: yum install -y postgresql-libs postgresql-devel)
* npm
  - [X] npm test unit (ChaiJS, TV4, Newman)
* js package manager
  - [X] yarn
  - [X] bower
  - [X] grunt
  - [X] gulp
  - [X] yeoman
* composer

## Configuration:
* Generate ssh key for your access:
  ```
  ssh-keygen -t rsa
  ```
* Add your id_rsa.pub to environment (.env) file
* Add your id_rsa.pub to SSH_AUTHORIZED_KEYS in Dockerfile
* Rebuild your docker container
  ```
  docker-compose build && docker-compose up --force-recreate
  ```
* Check your IP Address container
  - Show running container docker
    ```
    docker ps
    ```
  - Show the IP Address container
    ```
    docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' [container_name_or_id]
    ```
    * Read [this](http://stackoverflow.com/questions/17157721/getting-a-docker-containers-ip-address-from-the-host)
  - Inspect container
    ```
    docker inspect [name_container]
    ```
    (eg: application_1)
* Access ssh
  - Run: 
    ```
    ssh docker@[ip_address_container]
    ```
  - Superuser access (root):
    ```
    sudo su
    ``` 
    (password: **docker**)

## License
GNU General Public License v2
