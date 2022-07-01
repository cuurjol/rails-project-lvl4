# Application Github Quality

Github Quality is an application-clone of the famous platform [Code Climate](https://codeclimate.com/).
It is a service where users can run code checks in their repositories and get a report on the state
of the codebase, current errors.

[![Actions Status](https://github.com/cuurjol/rails-project-lvl4/workflows/hexlet-check/badge.svg)](https://github.com/cuurjol/rails-project-lvl4/actions)
[![CI](https://github.com/cuurjol/rails-project-lvl4/actions/workflows/main.yml/badge.svg)](https://github.com/cuurjol/rails-project-lvl4/actions/workflows/main.yml)

## Installation and running

To run the application, do the following commands in your terminal window:

* Clone the repository from GitHub and navigate to the application folder:
```
git clone https://github.com/cuurjol/rails-project-lvl4.git
cd rails-project-lvl4
```

* Install the necessary application gems specified in the `Gemfile`:
```
bundle install
```

* Create a database, run database migrations and a `seeds.rb` file to create database records:
```
# Make command:
make db-setup

# Run each command separately:
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed
```

The application uses the `SQLite` database for development/test environment and the `Postgresql` database for
production environment.

* Set up ENV settings in `.env` file:
```
# .env.example:
# For development and production environments:
BASE_URL=BASE_URL
GITHUB_CLIENT_ID=GITHUB_CLIENT_ID
GITHUB_CLIENT_SECRET=GITHUB_CLIENT_SECRET

# For production environment:
MAILTRAP_SMTP_USER_NAME=GOOGLE_SMTP_USER_NAME
MAILTRAP_SMTP_PASSWORD=GOOGLE_SMTP_PASSWORD
```

The application uses the `Github` authentication from [Omniauth](https://github.com/omniauth/omniauth) gem
and [Mailtrap](https://mailtrap.io/) SMTP server.

* Launch the application (local server):
```
bundle exec rails server
```

## Heroku deployment

Study project is ready for deployment on the Heroku. The working version of the project can be viewed at
[Heroku website](https://cuurjol-hexlet-github-quality.herokuapp.com/).

## Author

**Kirill Ilyin**, study project from [Hexlet](https://ru.hexlet.io/)
