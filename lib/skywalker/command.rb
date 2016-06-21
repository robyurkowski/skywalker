require 'skywalker/callable'
require 'skywalker/transactional'

module Skywalker
  class Command
    include Callable
    include Transactional
  end
end
