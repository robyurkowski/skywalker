All commits by Rob Yurkowski unless otherwise noted.

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
