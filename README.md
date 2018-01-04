== README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version: 2.5

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

Initial seed command to mongodb: 
```terminal
rake db:seed
```

```terminal
rails runner 'Delayed::Backend::Mongoid::Job.create_indexes'
```

Local deployment: 
bundle exec unicorn -p 8080 -c ./config/unicorn.rb

activation of async process (delayed job)
```terminal
bin/delayed_job start 
```

to turn off async process, do the following:
```terminal
#bin/delayed_job stop
```
default username and password for admin portal: 
```
username: admin
password: admin
```

* ...


Please feel free to use a different markup language if you do not plan to run
<tt>rake doc:app</tt>.

###### tutorial link for mongoid: 
http://railscasts.com/episodes/238-mongoid?view=asciicast

```terminal
#generate mongoid database config
```

```terminal
rails g mongoid:config
```

generate delayed job script after creating index
```terminal
rails runner 'Delayed::Backend::Mongoid::Job.create_indexes'
```

###### scaffold model example
```terminal
rails g scaffold ute_experiment experiment_code:string title:string text:text is_private:boolean is_active:boolean 
```
