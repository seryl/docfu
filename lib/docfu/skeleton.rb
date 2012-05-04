module Docfu::Skeleton  
  class << self
    # Sets up a new directory structure for a document project.
    # 
    # @param [ String ] folder The project path.
    def setup_directory_structure(folder)
      Dir.mkdir(folder) unless Dir.exists? folder
      %w( figures figures-dia figures-source ).each do |fold|
        Dir.mkdir("#{folder}/#{fold}") unless Dir.exists? "#{folder}/#{fold}"
      end
      setup_rakefile(project_folder)
      setup_readme(project_folder)
      write_config_yml(project_folder)
      write_info_yml(project_folder)
    end
    
    # The location of the templates folder.
    def templates_location
      File.join(File.expand_path(File.dirname(__FILE__)), 'templates')
    end
    
    # Sets up the Rakefile for the project.
    # 
    # @param [ String ] project The name of the new project.
    def setup_rakefile(project)
      rake_erb_file = "#{templates_location}/Rakefile.erb"
      rake_template = ERB.new(IO.read(rake_erb_file))
      unless file.exists? "#{project}/Rakefile"
        File.open("#{project}/Rakefile", 'w') { |f|
          f.write(rake_template.result(binding))
        }
      end
    end
    
    # Sets up the README for the project.
    # 
    # @param [ String ] project The name of the new project.
    def setup_readme(project)
      readme_erb_file = "#{templates_location}/README.md.erb"
      readme_template = ERB.new(IO.read(readme_erb_file))
      unless file.exists? "#{project}/README.md"
        File.open("#{project}/README.md", 'w') { |f|
          f.write(readme_template.result(binding))
        }
      end
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
        'figures', 'figures-dia', 'figures-source', 'README'
      ]
      sane_config['exclude'] = sane_config['exclude'] | exclude_defaults
      YAML.dump(sane_config)
    end
    
    # Writes the config.yml if it's missing for the current project,
    # otherwise it returns early.
    # 
    # @param [ Hash ] config The config hash to pass.
    def write_config_yml(project, config)
      config_file = "#{project}/config.yml"
      unless File.exists? config_file
        puts "Creating config.yml..."
        cfg = generate_config_yml(config)
        File.open(config_file, 'w') { |f| f.write(cfg) }
      end
    end
    
    # Takes an info hash and converts it into it's yaml equivalent config.yml.
    # 
    # @param [ Hash ] config The config hash to convert into the config.yml.
    # 
    # @return [ String ] The configuration yml in string format.
    def generate_info_yml(config)
      sane_config = config.map {|k, v| { k.to_s => v } } 
      sane_config['author'] ||= 'author'
      sane_config['title'] ||= 'title'
      exclude_defaults = [
        'figures', 'figures-dia', 'figures-source', 'README.md'
      ]
      sane_config['exclude'] = sane_config['exclude'] | exclude_defaults
      YAML.dump(sane_config)
    end
    
    # Writes the info.yml if it's missing for the current project,
    # otherwise it returns early.
    # 
    # @param [ Hash ] info The info hash to pass.
    def write_info_yml(project, info)
      unless File.exists? "#{project}/info.yml"
        puts "Creating info.yml..."
        inf = generate_info_yml(info)
        File.open("#{project}/info.yml", 'w') { |f|
          f.write(inf)
        }
      end
    end
  
  end
end
