Login Syncinator
=================

Login Syncinator is a temporary tool to sync personal emails from [trogdir-api](https://github.com/biola/trogdir-api) into the legacy login application.
Eventually, a new application will replace the login application and use trogdir-api directly, but until then, this exists to keep trogdir-api and login in sync.

Requirements
------------
- Ruby
- Redis server (for Sidekiq)
- Read access to login MySQL database
- trogdir-api installation

Installation
------------
```bash
git clone git@github.com:biola/login-syncinator.git
cd login-syncinator
bundle install
cp config/settings.local.yml.example config/settings.local.yml
cp config/blazing.rb.example config/blazing.rb
```

Configuration
-------------
- Edit `config/settings.local.yml` accordingly.
- Edit `config/blazing.rb` accordingly.

Running
-------

```ruby
sidekiq -r ./config/environment.rb
```

Console
-------
To launch a console, `cd` into the app directory and run `irb -r ./config/environment.rb`

Deployment
----------
```bash
blazing setup [target name in blazing.rb]
git push [target name in blazing.rb]
```
