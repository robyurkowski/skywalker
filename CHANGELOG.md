All commits by Rob Yurkowski unless otherwise noted.

## 2.2.0 (2016-06-21)

- Extracts command behaviour to `Skywalker::Callable` and
  `Skywalker::Transactional`.

  This simplifies the `Command` object, making it basically a combination of
  `Callable` and `Transactional` mixins. It also allows for the reuse of the
  constituent parts on a larger scale.

- Remove dependency on `ActiveRecord`.

  We now do a check to see if ActiveRecord is defined. If not, we simply default
  to calling the passed block. This allows us to avoid having to require
  ActiveRecord, which lightens our dependencies and also makes us feel just a
  tiny bit less dirty.

## 2.1.0 (2015-05-14)

- Yields self to any block given to any object implementing `Skywalker::Acceptable`.

  This has a few ramifications; first, it allows some easy extension simply by
  passing a block to the constructor, as such:

  ```ruby
  a = MyObject.new(an_argument: :foo) { |instance| instance.an_argument = :bar }
  a.an_argument # => :bar
  ```

  More importantly, it allows for simpler subclassing:

  ```ruby
  class MyCommand < Skywalker::Command
    def initialize(*args)
      super do
        a_symbol = :new_symbol
      end
    end
  end
  ```

## 2.0.0 (2015-05-02)

- Refactors guts of commands to extract kwarg instantiation pattern into `Acceptable` module.
- Improves inline documentation.

## 1.2.2 (2015-03-26)

- Loosen restrictions on ActiveRecord version.

## 1.2.1 (2014-11-23)

- Fix a bug where callbacks would be called even if they were nil.

## 1.2.0 (2014-11-16)

- Add `required_args`, which allows marking certain attributes as required at initialization. Defaults to an empty list.
- Add testing section of README.
- Add example files.

## 1.1.0 (2014-11-03)

- Expanded documentation.
- Allow `on_success` and `on_failure` callbacks to be optional.
- Allow passing arbitrary values to command instantiation.
- Adds this changelog.

## 1.0.0 (2014-11-02)

- Initial creation.
