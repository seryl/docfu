module Docfu::Skeleton  
  class << self
    # Sets up a new directory structure for a document project.
    # 
    # @param [ String ] folder The project path.
    def setup_directory_structure(folder)
      Dir.mkdir(folder) unless Dir.exists? folder
      %w( figures figures-dia figures-source latex ).each do |fold|
        Dir.mkdir("#{folder}/#{fold}") unless Dir.exists? "#{folder}/#{fold}"
      end
    end
    
    # Sets up the Rakefile for the project.
    # 
    # @param [ String ] folder The project path.
    def setup_rakefile(folder)
    end
    
    # Sets up the README for the project.
    # 
    # @param [ String ] folder The project path.
    def setup_readme(folder)
      readme_data <<-EOH\# #{folder}
      
      EOH
    end
    
    # Takes an info hash and converts it into it's yaml equivalent config.yml.
    # 
    # @param [ Hash ] config The config hash to convert into the config.yml.
    # 
    # @return [ String ] The configuration yml in string format.
    def generate_config_yml(config)
      sane_config = config.map {|k, v| { k.to_s => v } } 
      sane_config['author'] ||= 'author'
      sane_config['title'] ||= 'title'
      exclude_defaults = [
        'figures','figures-dia', 'figures-source',
        'latex', 'README'        
      ]
      sane_config['exclude'] = { sane_config['exclude'] | exclude_defaults }
      YAML.dump(sane_config)
    end
    
    # Writes the config.yml if it's missing for the current project,
    # otherwise it returns early.
    # 
    # @param [ Hash ] config The config hash to pass to generate_config_yml.
    def write_config_yml_if_missing(config)
      if File.exists? config_file
        puts "config.yml already exists"
      end
      yml = generate_config_yml(config)
      IO.write(config_file, yml)
    end
    
    def config_file
      @config_file ||= File.join(File.dirname(Dir.pwd), 'config.yml')
    end
  end
end
