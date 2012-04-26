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
  docfu generate [ebook,pdf,html]
  """
  
  option :author,
    :short => "-a",
    :long  => "--author",
    :default => "author",
    :description => "The author of the document"
  
  option :title,
    :short => "-t",
    :long => "--title",
    :default => "title",
    :description => "The title of the document"
  
  option :help,
    :short => "-h",
    :long  => "--help",
    :description => "Show this message",
    :on => :tail,
    :boolean => true,
    :show_options => true,
    :exit => 0
  
  option :version,
    :short => "-v",
    :long  => "--version",
    :description => "Show docfu version",
    :boolean => true,
    :proc => lambda { |v| puts "docfu: #{::Docfu::VERSION}" },
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
end
