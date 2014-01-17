#
# Jekyll allows data to be specified in yaml format in the _data dir.
#
# If the data is an array, liquid allows one to build an index page.
# In some occasions, however, you also want to generate one page per record.
# Consider, e.g., a list of team members.
#
# This plugins allows one to specify data files for which we want to generate
# one page per record.
#
# The specification in config.yml is as follows:
#
# data_gen:
# - data: <<name of the data>>
#   template: <<name of the template to use to generate the page>>
#   name: <<field used to generate the filename>>
#   dir: <<directory in which files are to be generated>> 
#
# where:
# - @data@ is the name of the file to read
# - @name@ is the name of a field which contains a unique identifier that can 
#   be used to generate a filename
# - @template@ is the name of a template to generate the pages (it defaults to the value of @data@ + ".html")
# - @dir is the directory where pages are generated (it defaults to the value of @data@)
#
# A liquid tag is also made available to generate a link to a given page
#
# 

module Jekyll

  class DataPage < Page
    def initialize(site, base, dir, data, name, template)
      @site = site
      @base = base
      @dir = dir
      @name = sanitize_filename(data[name]) + ".html"

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), template + ".html")
      self.data.merge!(data)
      self.data['title'] = data[name]
    end

    private

    # copied from Jekyll
    def sanitize_filename(name)
      name = name.gsub(/[^\w\s_-]+/, '')
      name = name.gsub(/(^|\b\s)\s+($|\s?\b)/, '\\1\\2')
      name = name.gsub(/\s+/, '_')
    end
  end

  class DataPagesGenerator < Generator
    safe true

    def generate(site)
      data = site.config['page_gen']
      if data
        data.each do |data_spec|
          # todo: check input data correctness
          data_file = '_data/' + data_spec['data'] + ".yml"
          template = data_spec['template'] || data_spec['data']
          name = data_spec['name']
          dir = data_spec['dir'] || data_spec['data']
          
          if File.exists?(data_file) and site.layouts.key? template
            records =  YAML.load(File.read(data_file))
            records.each do |record|
              site.pages << DataPage.new(site, site.source, dir, record, name, template)
            end
          else
            puts "error. could not find #{data_file}" if not File.exists?(data_file)
            puts "error. could not find template #{template}" if not site.layouts.key? template
          end
        end
      end
    end
  end

  module DataPageLinkGenerator
    # use it like this: {{input | datapage_url: dir}}
    # output: dir / input .html
    def datapage_url(input, dir)
      dir + "/" + sanitize_filename(input) + ".html"
    end

    private

    # copied from Jekyll
    def sanitize_filename(name)
      name = name.gsub(/[^\w\s_-]+/, '')
      name = name.gsub(/(^|\b\s)\s+($|\s?\b)/, '\\1\\2')
      name = name.gsub(/\s+/, '_')
    end
  end

end

Liquid::Template.register_filter(Jekyll::DataPageLinkGenerator)

