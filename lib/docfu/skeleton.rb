# -*- coding: utf-8 -*-
module Docfu::Skeleton  
  class << self
    # Sets up a new directory structure for a document project.
    # 
    # @param [ String ] folder The project path.
    def setup_directory_structure(folder)
      Dir.mkdir(folder) unless Dir.exists? folder
      %w( figures figures-dia figures-source en ).each do |fold|
        Dir.mkdir("#{folder}/#{fold}") unless Dir.exists? "#{folder}/#{fold}"
      end
      setup_readme(folder)
    end
    
    # The location of the files folder.
    def files_location
      File.join(File.expand_path(File.dirname(__FILE__)), 'files')
    end
    
    # The location of the templates folder.
    def templates_location
      File.join(File.expand_path(File.dirname(__FILE__)), 'templates')
    end
    
    # Sets up the README for the project.
    # 
    # @param [ String ] project The name of the new project.
    def setup_readme(project)
      readme_erb_file = "#{templates_location}/README.md.erb"
      readme_template = ERB.new(IO.read(readme_erb_file), 0, '<>')
      unless File.exists? "#{project}/README.md"
        File.open("#{project}/README.md", 'w') { |f|
          f.write(readme_template.result(binding))
        }
      end
    end
    
    # Writes the config.yml if it's missing for the current project,
    # otherwise it returns early.
    def write_config_yml(project)
      config_file = "#{project}/config.yml"
      unless File.exists? config_file
        puts "Creating config.yml..."
        cfg = File.open("#{files_location}/config.yml", 'r').read
        File.open(config_file, 'w') { |f| f.write(cfg) }
      end
    end
    
    # Takes an info hash and converts it into it's yaml equivalent config.yml.
    # 
    # @param [ Hash ] config The config hash to convert into the config.yml.
    # 
    # @return [ String ] The configuration yml in string format.
    def generate_info_yml(config)
      sane_config = config.inject({}) {|res, (k,v)| res[k.to_s] = v; res }
      sane_config['author'] ||= 'author'
      sane_config['title'] ||= 'title'
      sane_config['exclude'] = sane_config['exclude'].split(",")
      info_erb_file = "#{templates_location}/info.yml.erb"
      info_template = ERB.new(IO.read(info_erb_file), 0, '<>')
      info_template.result(binding)
    end
    
    # Writes the info.yml if it's missing for the current project,
    # otherwise it returns early.
    # 
    # @param [ Hash ] info The info hash to pass.
    def write_info_yml(project, info)
      unless File.exists? "#{project}/info.yml"
        puts "Creating info.yml..."
        inf = generate_info_yml(info)
        File.open("#{project}/info.yml", 'w') { |f| f.write(inf) }
      end
    end
  
  end
end
