require 'spec_helper'

%w(commands).each do |pattern|
  path = File.expand_path("../../app/#{pattern}", __FILE__)
  $:.push path unless $:.include?(path)
end
