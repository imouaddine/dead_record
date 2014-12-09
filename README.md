# DeadRecord

[![Build Status](https://travis-ci.org/imouaddine/dead_record.svg?branch=master)](https://travis-ci.org/imouaddine/dead_record)

[![Coverage Status](https://img.shields.io/coveralls/imouaddine/dead_record.svg)](https://coveralls.io/r/imouaddine/dead_record)


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

This gem assumes that you already have a deleted_at column in your model table.

* To destroy an object:
```ruby
   model.destroy
```


* To destory an object for real:
```ruby
    model.destroy_for_real
```



* To restore an object:
```ruby
   model.restore
```

* To not override the default scope

```ruby
    class Record < ActiveRecord::Base
        acts_as_dead_record(override_default_scope: false)
    end
```

* To get the collection of the deleted elements

```ruby
   Record.only_deleted
```

* To get the collection of the  all elements including the deleted ones

```ruby
   Record.with_deleted
```

* To set a callback for destroy
```ruby
    class Record < ActiveRecord::Base
        acts_as_dead_record

        before_destroy :some_method
        around_destroy :some_method
        after_destroy :some_method
    end
```

* To set a callback for restore

```ruby
    class Record < ActiveRecord::Base
        acts_as_dead_record

        before_restore :some_method
        around_restore :some_method
        after_restore :some_method
    end
```


* To delete associated models

```ruby
   model.destroy(include_associations: true)
```

It would only work for has_many and has_one association. They should have dependent: :destroy option and the associated model should be a dead record as well.





## Contributing

1. Fork it ( https://github.com/[my-github-username]/dead_record/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
