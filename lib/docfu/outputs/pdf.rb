# -*- coding: utf-8 -*-
$:.unshift File.dirname(__FILE__)
require 'base'

module Docfu
  class Pdf < BaseOutput
    def generate(languages, debug)
      create_output_dir unless File.exists? output_dir
      figures do
        languages.each do |lang|
          cfg = config['default'].merge(config[lang]) rescue config['default']
          template = ERB.new(IO.read(tex_template), 0, '<>')
      
          puts "#{lang}:"
          markdown = Dir["#{project_home}/#{lang}/*/*.md"].sort.map do |file|
            File.read(file)
          end.join("\n\n")
      
          print "  Parsing markdown... "
          latex = IO.popen('pandoc -p --no-wrap -f markdown -t latex', 'w+') do |pipe|
            pipe.write(pre_pandoc(markdown, cfg))
            pipe.close_write
            post_pandoc(pipe.read, cfg)
          end
          puts "done"
      
          print "  Creating main.tex for #{lang}... "
          dir = "#{project_home}/#{lang}"
          mkdir_p(dir)
          File.open("#{dir}/main.tex", 'w') do |file|
            file.write(template.result(binding))
          end
          puts "done"
      
          abort = false
      
          puts "Running XeTeX:"
          cd(project_home)
          3.times do |i|
            print "    Pass #{i + 1}... "
            IO.popen("xelatex -output-directory=\"#{output_dir}\" \"#{dir}/main.tex\" 2>&1") do |pipe|
              unless debug
                if ~ /^!\s/
                  puts "failed with:\n      #{$_.strip}"
                  puts "  Consider running this again with --debug."
                  abort = true
                end while pipe.gets and not abort
              else
                STDERR.print while pipe.gets rescue abort = true
              end
            end
            break if abort
            puts "done"
          end
      
          unless abort
            print "  Moving output to #{info['title'].split(' ').join('_')}.#{lang}.pdf... "
            ["aux", "log", "out", "toc"].each { |f| rm "#{output_dir}/main.#{f}" }
            mv("#{output_dir}/main.pdf", "#{output_dir}/#{info['title'].split(' ').join('_')}.#{lang}.pdf")
            puts "done"
          end
        end
      end
    end
    
    def required_commands
      ['pandoc', 'xelatex']
    end
    
    def output_dir
      "#{project_home}/pdf"
    end
    
    def create_output_dir
      FileUtils.mkdir_p(output_dir)
    end
    
    def tex_template
      "#{Docfu::Skeleton.templates_location}/book.tex"
    end
    
    def replace(string, &block)
      string.instance_eval do
        alias :s :gsub!
        instance_eval(&block)
      end
      string
    end
    
    def verbatim_sanitize(string)
      string.gsub('\\', '{\textbackslash}').
        gsub('~', '{\textasciitilde}').
        gsub(/([\$\#\_\^\%])/, '\\\\' + '\1{}')
    end
    
    def pre_pandoc(string, cfg)
      replace(string) do
        # Pandoc discards #### subsubsections #### - this hack recovers them
        s(/\#\#\#\# (.*?) \#\#\#\#/, 'SUBSUBSECTION: \1')

        # Turns URLs into clickable links
        s(/\`(http:\/\/[A-Za-z0-9\/\%\&\=\-\_\\\.]+)\`/, '<\1>')
        s(/(\n\n)\t(http:\/\/[A-Za-z0-9\/\%\&\=\-\_\\\.]+)\n([^\t]|\t\n)/, '\1<\2>\1')

        # Process figures
        s(/Insert\s18333fig\d+\.png\s*\n.*?\d{1,2}-\d{1,2}\. (.*)/, 'FIG: \1')
      end
    end
    
    def post_pandoc(string, cfg)
      replace(string) do
        space = /\s/

        # Reformat for the book documentclass as opposed to article
        s('\section', '\chap')
        s('\sub', '\\')
        s(/SUBSUBSECTION: (.*)/, '\subsubsection{\1}')

        # Enable proper cross-reference
        s(/#{cfg['fig'].gsub(space, '\s')}\s*(\d+)\-\-(\d+)/, '\imgref{\1.\2}')
        s(/#{cfg['tab'].gsub(space, '\s')}\s*(\d+)\-\-(\d+)/, '\tabref{\1.\2}')
        s(/#{cfg['prechap'].gsub(space, '\s')}\s*(\d+)(\s*)#{cfg['postchap'].gsub(space, '\s')}/, '\chapref{\1}\2')

        # Miscellaneous fixes
        s(/FIG: (.*)/, '\img{\1}')
        s('\begin{enumerate}[1.]', '\begin{enumerate}')
        s(/(\w)--(\w)/, '\1-\2')
        s(/``(.*?)''/, "#{cfg['dql']}\\1#{cfg['dqr']}")

        # Typeset the maths in the book with TeX
        s('\verb!p = (n(n-1)/2) * (1/2^160))!', '$p = \frac{n(n-1)}{2} \times \frac{1}{2^{160}}$)')
        s('2\^{}80', '$2^{80}$')
        s(/\sx\s10\\\^\{\}(\d+)/, '\e{\1}')

        # Convert inline-verbatims into \texttt (which is able to wrap)
        s(/\\verb(\W)(.*?)\1/) do
          "{\\texttt{#{verbatim_sanitize($2)}}}"
        end

        # Ensure monospaced stuff is in a smaller font
        s(/(\\verb(\W).*?\2)/, '{\footnotesize\1}')
        s(/(\\begin\{verbatim\}.*?\\end\{verbatim\})/m, '{\footnotesize\1}')

        # Shaded verbatim block
        s(/(\\begin\{verbatim\}.*?\\end\{verbatim\})/m, '\begin{shaded}\1\end{shaded}')
      end
    end
    
  end
end
