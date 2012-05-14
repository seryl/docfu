# -*- coding: utf-8 -*-
# The commandline docfu application.
class Docfu::Application
  include Mixlib::CLI
  
  # Default aliases for running docfu commands.
  DEFAULT_ALIASES = {
    :create_new_project => ['new', 'create', 'n'],
    :generate_output    => ['generate', 'make', 'g']
  }
  
  banner """Example usage:
  docfu new [document]
  docfu generate
  docfu generate [pdf,ebook,html]
  """
  
  option :author,
    :short => "-a AUTHOR",
    :long  => "--author AUTHOR",
    :default => "author",
    :description => "The author of the document"
    
  option :exclude,
    :short => "-e EXLCUDE",
    :long  => "--exclude EXCLUDE",
    :default => 'figures,figures-dia,figures-source,README.md',
    :description => "The list of files and directories to exclude from scripts"
  
  option :title,
    :short => "-t TITLE",
    :long  => "--title TITLE",
    :default => "title",
    :description => "The title of the document"
    
  option :language,
    :short => "-l LANGUAGE",
    :long  => "--language LANGUAGE",
    :default => "en",
    :description => "The languages to build - defaults to english [en]"
    
  option :debug,
    :short => "-d",
    :long  => "--debug",
    :description => "Enable debugging",
    :boolean => true,
    :default => false
  
  option :version,
    :short => "-v",
    :long  => "--version",
    :description => "Show docfu version",
    :boolean => true,
    :proc => lambda { |v| puts "docfu: #{::Docfu::VERSION}" },
    :exit => 0
  
  option :help,
    :short => "-h",
    :long  => "--help",
    :description => "Show this message",
    :on => :tail,
    :boolean => true,
    :show_options => true,
    :exit => 0
  
  def run
    trap("INT") { exit 0 }
    parse_options
    run_commands
  end
  
  def aliases(cmd)
    DEFAULT_ALIASES.each { |k, v| return k if v.include?(cmd) }
    nil
  end
  
  def run_commands
    if ARGV.size == 0 || aliases(ARGV.first).nil?
      puts self.opt_parser.help
      exit 0
    else
      send(aliases(ARGV.first).to_sym)
    end
  end
  
  def create_new_project
    project_folder = (ARGV.size >= 2) ? ARGV.last : nil
    puts "Creating new project #{project_folder}"
    Docfu::Skeleton.setup_directory_structure(project_folder)
    Docfu::Skeleton.write_config_yml(project_folder)
    Docfu::Skeleton.write_info_yml(project_folder, config)
    puts "Complete."
  end
  
  def generate_output
    gen_type = (ARGV.size >= 2) ? ARGV.last : 'pdf'
    invalid_type_error unless ['pdf', 'ebook', 'html'].include? gen_type
    out = Docfu.const_get(gen_type.capitalize).new
    out.check_missing_commands
    out.check_valid_project
    out.generate(config[:language].split(','), config[:debug])
  end
  
  def invalid_type_error
    puts "Error: invalid type. Please use one of `pdf, ebook, html`."
    exit 0
  end
end
