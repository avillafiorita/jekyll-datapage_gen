Gem::Specification.new do |s|
  s.metadata= { "source_code_uri" => "https://github.com/avillafiorita/jekyll-datapage_gen" }
  s.version = "1.0.0"
  s.summary = "Generate one page per yaml record in Jekyll sites."
  s.license = ['MIT']
  s.authors = ['Adolfo Villafiorita']
  s.email   = ['adolfo.villafiorita@fbk.eu']
  s.files = Array.new
  if File.exist?('data-page-generator.rb')
    s.files.push('data-page-generator.rb')
  end
  if File.directory?('lib')
    s.files.concat(Dir['lib'])
  end
end
