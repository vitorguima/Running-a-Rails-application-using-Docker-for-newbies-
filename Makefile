start:
	docker-compose up
bash:
	docker-compose exec web bash
console:
	docker-compose exec web bundle exec rails c
# specs:
# 	docker-compose exec web bundle exec rspec spec