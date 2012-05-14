$:.unshift File.join(File.dirname(__FILE__), 'docfu')
require 'erb'
require 'fileutils'
require 'yaml'

require 'mixlib/cli'

# Document like a ninja
module Docfu
  VERSION = '0.0.3'
end

require 'docfu/outputs'
require 'docfu/skeleton'
require 'docfu/application'
