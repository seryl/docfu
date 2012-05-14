# -*- coding: utf-8 -*-
module Docfu
  class BaseOutput
    include FileUtils
    
    def generate(languages, debug)
      puts "This output class has not been implemented"
      exit 0
    end
    
    def required_commands
      []
    end
    
    def check_missing_commands
      missing = required_commands.reject{|command| command_exists?(command)}
      unless missing.empty?
        puts "Missing dependencies: #{missing.join(', ')}."
        puts "Install these and try again."
        exit 0
      end
    end
    
    def project_home
      @home ||= Dir.pwd
    end
    
    def command_exists?(command)
      if File.executable?(command) then
        return command
      end
      ENV['PATH'].split(File::PATH_SEPARATOR).map do |path|
        cmd = "#{path}/#{command}"
        File.executable?(cmd) \
        ||  File.executable?("#{cmd}.exe") \
        ||  File.executable?("#{cmd}.cmd")
      end.inject{|a, b| a || b}
    end
    
    def check_valid_project
      not_a_project_error unless contains_info_yaml? and contains_config_yaml?
    end
    
    def contains_info_yaml?
      File.exists? "#{project_home}/info.yml"
    end
    
    def contains_config_yaml?
      File.exists? "#{project_home}/config.yml"
    end
    
    def info
      @info ||= YAML::load(File.open("#{project_home}/info.yml"))
    end
    
    def config
      @config ||= YAML::load(File.open("#{project_home}/config.yml"))
    end
    
    def not_a_project_error
      puts "This directory doesn't appear to be docfu repository."
      puts "To create a new docfu repository type: docfu new [document]"
      exit 0
    end
    
    def figures(&block)
      begin
        Dir["#{project_home}/figures/18333*.png"].each do |file|
          cp(file, file.sub(/18333fig0(\d)0?(\d+)\-tn/, '\1.\2'))
        end
        block.call
      ensure
        Dir["#{project_home}/figures/18333*.png"].each do |file|
          rm(file.gsub(/18333fig0(\d)0?(\d+)\-tn/, '\1.\2'))
        end
      end
    end
    
  end
end
