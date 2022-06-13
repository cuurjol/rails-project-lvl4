install:
	bundle install
	yarn install
	bundle exec rails db:prepare

db-drop:
	bundle exec rails db:drop

db-migrate:
	bundle exec rails db:migrate

db-setup:
	bundle exec rails db:create db:migrate db:seed

db-reset:
	bundle exec rails db:drop db:create db:migrate db:seed

console:
	bundle exec rails console

linters:
	bundle exec rubocop
	bundle exec slim-lint app/views

test:
	bundle exec rails test

heroku-deploy:
	git push heroku main

heroku-console:
	heroku run rails console

heroku-logs:
	heroku logs --tail

.PHONY: test
