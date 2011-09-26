Remotely drive your ShowOff presentation on remote users' terminals.

## Setup
This gem is preconfigured to use the Heroku addon format for Pusher configs. These instructions assume you've already set up your ShowOff presentation for Heroku (`showoff heroku`).

### Install Pusher addon

```bash
heroku addons:add pusher
heroku config
# => PUSHER_SOCKET_URL   => ws://ws.pusherapp.com:80/app/PUSHER_SOCKET_ID
# => PUSHER_URL          => http://PUSHER_KEY:PUSHER_SECRET@api.pusherapp.com/apps/PUSHER_APP_ID
```

### Add showoff-pusher to your Gemfile

```ruby
gem 'showoff-pusher'
```

### Add ShowOff::Pusher to your config.ru rackup file

```ruby
require "showoff"
require "showoff/pusher"

use ShowOff::Pusher
run ShowOff.new
```

### Load the required javascripts in your first slide

```markdown
!SLIDE 
# My Presentation #

<script src="http://js.pusherapp.com/1.9/pusher.min.js"></script>
<script src="/javascripts/pusher.js"></script>
```

### Optional: Customize your secret

```bash
heroku config:add SHOWOFF_SECRET='some_super_secret_key'
```

## Usage

In your browser, visit the following URL to control the presentation:

`http://myapp.herokuapp.com/presenter?presenter=SHOWOFF_SECRET`

By default, `SHOWOFF_SECRET` is `PleaseChangeMe`.

Your users will be able to follow along with the presentation by visiting `http://myapp.herokuapp.com/`

## Notes
Adapted from lmarburger's gist: https://gist.github.com/1180118
