# Skywalker

Skywalker is a gem that provides a simple command pattern for applications that use transactions.

## Why Skywalker?

It's impossible to come up with a single-word name for a gem about commands that's at least marginally
witty. If you can't achieve wit or cleverness, at least achieve topicality, right?

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

### Knowledge of Results Without Knowledge of Response

A command prescriptively takes callbacks or `#call`able objects, which can be called
depending on the result of the command. By default, `Skywalker::Command` can handle
an `on_success` and an `on_failure` callback, which are called after their respective
results. You can define these in your controllers, which lets you run the same command
but respond in unique ways, and keeps controller concerns inside the controller.

You can also easily override which callbacks are run. Need to run a different callback
if `request.xhr?`? Simply override `run_success_callbacks` and `run_failure_callbacks`
and call your own.

### A Gateway to Harder Architectures

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

Let's talk about a situation where you're creating a group and sending an email inside a
Rails app.

Standard operating procedure usually falls into one of two patterns, both of which are
mediocre. The first makes use of ActiveRecord callbacks:

```ruby
# app/controllers/groups_controller.rb
class GroupsController < ApplicationController
  # ...

  def create
    @group = Group.new(params.require(:group).permit(:name))

    if @group.save
      redirect_to @group, notice: "Created the group!"
    else
      flash[:alert] = "Oh no, something went wrong!"
      render :new
    end
  end
end


# app/models/group.rb
class Group < ActiveRecord::Base
  after_create :send_notification

  private

  def send_notification
    NotificationMailer.group_created_notification(self).deliver
  end
end
```

This might seem concise because it keeps the controller small. (Fat model,
thin controller has been a plank of Rails development for a while, but it's
slowly going away, thank heavens). But there are two problems here:
first, it introduces a point of coupling between the model and the mailer,
which not only makes testing slower, it means that these two objects are
now entwined. Create a group through the Rails console? You're sending an email with
no way to skip that. Secondly, it reduces the reasonability of the code. When you
look at the `GroupsController`, you can't suss out the fact that this sends an email.

**Moral #1: Orthogonal concerns should not be put into ActiveRecord callbacks.**

The alternative is to keep this inside the controller:

```ruby
# app/controllers/groups_controller.rb
class GroupsController < ApplicationController
  # ...

  def create
    @group = Group.new(params.require(:group).permit(:name))

    if @group.save
      NotificationMailer.group_created_notification(@group).deliver
      redirect_to @group, notice: "Created the group!"
    else
      flash[:alert] = "Oh no, something went wrong!"
      render :new
    end
  end
end
```

This is more reasonable, but it's longer in the controller and at some point your eyes
begin to glaze over. Imagine as these orthogonal concerns grow longer and longer. Maybe
you're sending a tweet about the group, scheduling a background job to update some thumbnails,
or hitting a webhook URL. You're losing the reasonability of the code because of the detail.

Moreover, imagine that the group email being sent contains critical instructions on how
to proceed. What if `NotificationMailer` has a syntax error? The group is created, but the
mail won't be sent. Now the user hasn't gotten a good error, and your database is potentially
fouled up by half-performed requests. You can run this in a transaction, but that does not
reduce the complexity contained within the controller. 

**Moral #2: Rails controllers should dispatch to application logic, and receive instructions on how to respond.**

The purpose of the command is to group orthogonal but interdependent results into logical operations. Here's how that
looks with a `Skywalker::Command`:


```ruby
# app/controllers/groups_controller.rb
class GroupsController < ApplicationController
  # ...

  def create
    CreateGroupCommand.call(
      group:      Group.new(params.require(:group).permit(:name)),
      on_success: method(:on_create_success),
      on_failure: method(:on_create_failure)
    )
  end


  def on_create_success(command)
    redirect_to command.group, notice: "Created the group!"
  end


  def on_create_failure(command)
    flash[:alert] = "Oh no, something went wrong!"
    @group = command.group
    render :new
  end
end


# app/commands/create_group_command.rb
class CreateGroupCommand < Skywalker::Command
  def execute!
    save_group!
    send_notification!
  end


  private def save_group!
    group.save!
  end


  private def send_notifications!
    notifier.call(group).deliver
  end


  private def notifier
    @notifier ||= NotificationsMailer.method(:group_created_notification)
  end
end
```

You can of course set up a default for Group as with `#notifier` and pass in
params only, but I find injecting a pre-constructed ActiveRecord object usually
works well.


### Basic Composition Summary
Compose your commands:

```ruby
require 'skywalker/command'

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
  any_keyword_argument: "Is taken and has an attr_accessor defined for it."
)

```

You can pass any object responding to `#call` to the `on_success` and `on_failure` handlers, including procs, lambdas, controller methods, or other commands themselves.

### Overriding Methods

The following methods are overridable for easy customization:

- `execute!`
  - Define your operations here.
- `transaction(&block)`
  - Uses an `ActiveRecord::Base.transaction` by default, but can be customized. `execute!` runs inside of this.
- `confirm_success`
  - Fires off callbacks on command success (i.e. non-error).
- `run_success_callbacks`
  - Dictates which success callbacks are run. Defaults to `on_success` if defined.
- `confirm_failure`
  - Fires off callbacks on command failure (i.e. erroneous state), and sets the exception as `command.error`.
- `run_failure_callbacks`
  - Dictates which failure callbacks are run. Defaults to `on_failure` if defined.

For further reference, simply see the command file. It's less than 90 LOC and well-commented.

## Testing

To come.

## Contributing

1. Fork it ( https://github.com/robyurkowski/skywalker/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
