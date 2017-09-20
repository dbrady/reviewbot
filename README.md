# Hipbot

This is my fork of Robert Lude's reviewbot. There are many like it, but this is
mine.

## Heroku

Currently deployed to Heroku as dbrady-cmm-hipchat-bot.

How to deploy it: use the heroku CLI. I can't be arsed to integrate it with
our private
github. https://dashboard.heroku.com/apps/dbrady-cmm-hipchat-bot/deploy/heroku-git
But here's the TL;DR:

    # First Time Setup:
    $ heroku login
    $ heroku git:remote -a dbrady-cmm-hipchat-bot

    # Ever After:
    $ git push heroku master

## Testing the deploy

You'll get "Not Found" if you try to just go to the root domain. Go here instead
for my hello world:

https://dbrady-cmm-hipchat-bot.herokuapp.com/poo
