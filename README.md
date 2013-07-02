# Rnotifier

Exception catcher for rack base applications.

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

- environments: development  #Default is production
- capture_code: true         #Default false
- api_host: 'http://yourapp.com' #Default http://rnotifier.com

### To test config

rnotifier test  #This will send test exception to rnotifier.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

License
-------
This is released under the MIT license.
