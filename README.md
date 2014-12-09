# DeadRecord

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dead_record'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dead_record

## Usage

Add acts_as_dead_record to your model class

```ruby
    class Record < ActiveRecord::Base
        acts_as_dead_record
    end
```

This gem assumes that you already have a deleted_at column in your model table

* To destroy an object:
```ruby
   model.restore
```

* To restore an object:
```ruby
   model.restore
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/dead_record/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
