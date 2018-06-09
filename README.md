# Rabl::Extend::Compiler
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rabl-extend-compiler'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rabl-extend-compiler

## Usage

When using [Rabl](https://github.com/nesquena/rabl) there is a DSL method called `extend` which embeds another template in the current template and serves as a
mechanism to be DRY and maintain object definitions in a single place.

One signficant downsie of such a pattern is that the template rendering for large number of collections can be significantly lower (we have measured from 10-25% slower on collections up to 1000 objects)

In order to help facilitate still using Rabl (it's a great library) we dediced to write a few rake tasks that allow us the benefits of then extension system
without the drawbacks. Attempting to emulate something like what is mentioned in this [issue](https://github.com/nesquena/rabl/issues/500) and running rake tasks to verify or compile the extensions before moving to production.

This gem merely outlines the components and they may be used as you see fit at varying times in your infrastructure (we run the verification rake task in our CI pipeline)

The rake tasks are:

`rake rabl:extend:compiler:all` Runs all steps
`rake rabl:extend:compiler:reset` Will reset all signatures from the extended files
`rake rabl:extend:compiler:compile` Will compile and sign each use of `extend` in the code base
`rake rabl:extend:compiler:verify` Will `exit(1)` if the extensions are not compiled or the signatures do not match on the compiled extensions


The "signatures" encompass the attributes or files from an extension and are merely a SHA256 digest of the file contents during the compilation step and creates an easy and fast mechanism to determine if the extended files have been altered without updating the extensions.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rabl-extend-compiler.
