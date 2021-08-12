# How to create a Rails application using Docker

To follow this tutorial, the only thing you need is to have Docker installed in your computer. Previous knowledge about Docker or Rails isn't necessary. This a newbie to newbie documentation so you can use it "by the book" to start your studies or if you want to run a rails application using docker for the first time.

## Creating your app structure

### Step 1
Run this code line in your computer bash. It will run a new container with Ruby image

```bash
docker run -it -v $HOME:/var/home -w /var/home ruby:3.0.2 bash
```

### Step 2
Installing Ruby package manager (bundler). Run this code line in your computer bash.

```bash
gem install bundler
```

### Step 3
Installing Rails. Run this code line in your computer bash.

```bash
gem install rails
```

### Step 4
Creating your app. Run this code line in your computer bash. The command --database=postgresql is only necessary if you want to  work with postgre. By default, your application will be created using SQLite.

```bash
rails new dummy --database=postgresql
```

### Step 5
Installing node. Run this code line in your computer bash.

```bash
curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    echo 'deb https://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list &&\
    wget -q -O - https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - &&\
    apt-get update -qq && \
    apt-get install -y build-essential nodejs yarn
```

## Creating a Ruby container to start your application, to use  it's bash, console etc.

### Step 1
Creating a Dockerfile (it will contain the instructions to create your app image inside a container). Go inside your application and, at the global directory, create a document with the name 'Dockerfile'.

```Dockerfile
FROM ruby:3.0.2

RUN gem install bundler

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    echo 'deb https://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list &&\
    wget -q -O - https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - &&\
    apt-get update -qq && \
    apt-get install -y build-essential nodejs yarn

WORKDIR /var/app

COPY . .

RUN bundler install

ENTRYPOINT ["./entrypoint.sh"]
```

### Step 2
Creating an entrypoint (it will contain some commands that your application will run by default, if you dont specify any other command)

```entrypoint
#!/bin/bash
rm -f /var/app/tmp/pids/server.pid
bundle check > /dev/null 2>&1 || bundle install -j4
echo "> Executing 'yarn install' on web"
yarn install

if [ "$#" == 0 ]
then
    bundle exec rake db:create db:migrate
    exec bundle exec rails server -b '0.0.0.0'
fi
exec $@
```

### Step 3
Adding permission to your app execute it's entrypoint. Insert this command line in your bash, inside your app's directory.

```bash
chmod +x entrypoint.sh
```

### Step 4
Building your application. In other words, executing your Dockerfile. Insert this command line in your bash, inside your app's directory.

```bash
docker build -t myapp .
```

### Step 5
Starting your container. Insert this command line in your bash, inside your app's directory.

```bash
docker run -it myapp bash
```

### Step 6
Executing your container (remember, you started it before in the previous step). Insert this command line in your bash, inside your app's directory.

Get your container id, using this command line

```bash
docker ps
```
then execute it

```bash
docker exec -it "id do container" bash
```

## Creating a docker compose
Docker compose is a way to compose your application with diferent containers("services"). 

### Step 1
Inside your application's global directory, create a document with the name 'docker-compose.yml' with the following code block.

```Docker
version: '2'

services:
  web:
    build:
      context: .
    volumes:
      - .:/var/app
    ports:
      - '3000:3000'
  db:
      image: postgres:9.6.2-alpine
      ports:
          - '5432:5432'
      volumes:
          - postgres96:/var/lib/postgresql/data
volumes:
  postgres96:
```

### Step 2 (only if you don't have docker-compose installed in your computer)
Insert this command line in your bash, inside your app's directory. 

```bash
sudo apt install docker-compose
```

### Step 3
Building the docker-compose you have just created. Insert this command line in your bash, inside your app's directory. 

```bash
docker-compose up
```

### Step 4
If you get a webpack error, this will solve it. Insert this command line in your bash, inside your app's directory. 

Open your container bash
```bash
docker-compose run web bash
```
then install the webpacker
```bash
bundle exec rake webpacker:install
```

### Step 5
If you get a postgre error, this will solve it

- Search the document config/database.yml
- Inside it, search for the following code block:

```Rails
development:
...
"database: database name"
```

then change the "database" line to:

```Rails
url: postgres://postgres:@db:5432/dummy_development
```

Now search for the following code block:

```Rails
test:
...
"database: database name"
```

then change the "database" line to:

```Rails
test:
...
url: postgres://postgres:@db:5432/dummy_test
```

After finishing these changes, execute the command

```bash
docker-compose run web bash
```

## Creating a Makefile
A Makefile is a way to create shortcuts as commands to handle your application's usability.

### Step 1
Go inside your application and, at the global directory, create a document with the name 'Makefile'. Inside it, insert the following code block:

```Makefile
start:
	docker-compose up
bash:
	docker-compose exec web bash
console:
	docker-compose exec web bundle exec rails c
# specs:
# 	docker-compose exec web bundle exec rspec spec
```

### Step 2
Now, if you want to start your application, access it's bash or console, you can use:

```Bash
make start
make bash
make console
```

## License
[MIT](https://choosealicense.com/licenses/mit/)
