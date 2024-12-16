### Build the Docker images for production:
```bash
   docker compose -f docker-compose.production.yaml build
```
### Start the Chatwoot services:
```bash
   docker compose -f docker-compose.production.yaml up -d
   docker compose -f docker-compose.production.yaml up -d --remove-orphans
```
### Run the database migrations:
```bash
   docker compose -f docker-compose.production.yaml run --rm rails bundle exec rails db:chatwoot_prepare

## Create external network net
```bash
   docker network create net
```

### Check smtp settings
```bash
docker exec -it bdffe41bdfd6 /bin/sh
```
```ruby
# Get smtp settings
ActionMailer::Base.smtp_settings

# Fill values for appropriate settings
# Remove the keys which aren't relevant to your use case
smtp_settings = {
  address: 'smtp.gmail.com',
  port: '587',
  user_name: 'autobeta.dev@gmail.com',
  password: 'ygch jsyd qnde vock',
  domain: 'smtp.gmail.com',
  tls: true,
  enable_starttls_auto: true,
  openssl_verify_mode: 'none',
  authentication: 'plain',
}

mailer = ActionMailer::Base.new
# check settings:
mailer.delivery_method = :smtp
mailer.smtp_settings = ActionMailer::Base.smtp_settings

# replace with your values for the mail
mailer.mail(from: 'autobeta.dev@gmail.com', to: 'charmant@tut.by', subject: 'test', body: "Hello, you've got mail!").deliver
```



# Development

```bash
# build base image first
docker compose build base

# build the server and worker
docker compose build

# run the database migrations
docker compose run --rm rails bundle exec rails db:chatwoot_prepare

# seed the database
docker compose run --rm rails bundle exec make db_seed
docker compose run --rm rails bundle exec tmp:cache:clear

# run the server and worker
docker compose up


```
url: http://localhost:3000
user_name: john@acme.inc
password: Password1!