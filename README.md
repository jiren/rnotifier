# Rnotifier

Events and Exception catcher libraray.

[![Build Status](https://travis-ci.org/jiren/rnotifier.png?branch=master)](https://travis-ci.org/jiren/rnotifier) 
 [![Coverage Status](https://coveralls.io/repos/jiren/rnotifier/badge.png?branch=master)](https://coveralls.io/r/jiren/rnotifier?branch=master)
 [![Code Climate](https://codeclimate.com/github/jiren/rnotifier.png)](https://codeclimate.com/github/jiren/rnotifier)

## Installation

Add this line to your application's Gemfile:

    gem 'rnotifier'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rnotifier

## Usage

    rnotifier install 'API-KEY'  # This will create 'config/rnotifier.yaml' file.

### Config file options

    environments: development,test #default is production
    capture_code: true             #default false
    ignore_exceptions: ActiveRecord::RecordNotFound,AbstractController::ActionNotFound,ActionController::RoutingError
    ignore_bots: Googlebot

### To test config

    rnotifier test                 #this will send test exception to rnotifier.


### Send exception with request manually
    For this ':request' params require

    Rnotifier.exception(exception, {:request => request, other_params => 'value'})

### Add context data to exception

    Rnotifier.context({user_email: current_user.email})

### Send events and alerts

    Rnotifier.event(:sign_up, {:username => 'Jiren', :email => 'jiren@example.com', :using => 'facebook' })

    Rnotifier.alert(:order_fail, {:user => 'Jiren', :product => 'PS3', :order_id => '321' })


You can also sends tags with 'event' and 'alert'
i.e

    Rnotifier.event(
      :sign_up, 
      {:username => 'Jiren', :email => 'jiren@example.com', :using => 'facebook' },
      {:tags => ['newsletter']}
    )

### Benchmarking

1. Code block benchamrking

```ruby
Rnotifier.benchmark('sum') do
  (1..100).inject(0){|i, result| result =  result + i; result }
end
```

2. Method benchmarking

   - For Instance object method
      
```ruby
Paragraph.new.benchmark({args: true}).word_count(text)
```      
   - For class method
       
```ruby
Paragraph.benchmark({args: true}).word_count(text)
```      

   - Using helper function

```ruby
class Aggregator

  def error_count(options = {})
    # Code ...
  end
      
  # for instance method
  benchmark_it :error_count, :time_condition => 0.5

  def self.errors_by_date_range(start_date, end_date)
    # Code ...
  end

  # For class method
  benchmark_it :errors_by_date_range, :class_method => true

end
```      
     Options: time_condition and class_method
      - For class method pass option ':class_method => true'

  3. Rails action
    In controller add following filter.

```ruby
rnotifier_benchmarking # 
```
   Above will capture benchamrk for all controller action.

   For particular action

```
rnotifier_benchmarking only: [:index, :show]

# or 

rnotifier_benchmarking except: [:destroy]

```

    With time condition

```
 rnotifier_benchmarking only: [:index, :show], time_condition: 0.8
```

    To capture page load benchmarking on client side add following tag to your view in the end of your view or in footer
```
rnotifier_tag
```

## Contributing

  1. Fork it
  2. Create your feature branch (`git checkout -b my-new-feature`)
  3. Commit your changes (`git commit -am 'Add some feature'`)
  4. Push to the branch (`git push origin my-new-feature`)
  5. Create new Pull Request

  License
  -------
  This is released under the MIT license.
