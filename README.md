# Skywalker

Skywalker is a gem that provides a simple command pattern for applications that use transactions.

## Why Skywalker?

It's impossible to come up with a single-word clever name for a gem about commands. If you can't
achieve cleverness, achieve topicality.

## What is a command?

A command is simply a series of instructions that should be run in sequence
and considered a single unit. If one instruction fails, they should all fail.

That's a transaction, you say? You're correct! But there are some benefits of
considering transactional blocks as objects:

### Testability

With a command, you inject most any argument, which means that you can simulate
the run of the command without providing real arguments. Best practice is to
describe the operations in methods, which can then be stubbed out to test small
portions in isolation.

This also allows you to make the reasonable inference that the command will abort
properly if one step raises an error, and by convention, the same method (`on_failure`)
will be called. In most cases, you can thereby verify happy path and a single bad path
through integration specs, and that will suffice.

### Reasonability

The benefit of abstraction means that you can easily reason about a command without
having to know its internals. Standard caveats apply, but if you have a `CreateGroup`
command, you should be able to infer that calling the command with the correct arguments
will produce the expected result.

### A gateway to harder architectures

It's not hard to create an `Event` class and step up toward full event sourcing, or to
go a bit further and implement full CQRS. This is the architectural pattern your parents
warned you about.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'skywalker'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install skywalker

## Usage

Compose your commands:

```ruby
class AddGroupCommand < Skywalker::Command
  def execute!
    # Your transactional operations go here. No need to open a transaction.
    # Simply make sure each method raises an error when it fails.
  end
end
```

Then call your commands:

```ruby
command = AddGroupCommand.call(
  on_success: method(:on_success),
  on_failure: method(:on_failure)
)

```

You can pass any object responding to `#call` to the `on_success` and `on_failure` handlers, including procs, lambdas, controller methods, or other commands themselves.

## Contributing

1. Fork it ( https://github.com/robyurkowski/skywalker/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
