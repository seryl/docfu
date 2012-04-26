$:.unshift File.join(File.dirname(__FILE__), 'docfu')
require 'erb'
require 'yaml'

require 'mixlib/cli'

# Document like a ninja
module Docfu
  VERSION = '0.0.1'
end

require 'docfu/outputs'
require 'docfu/skeleton'
require 'docfu/application'
