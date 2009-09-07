require 'open-uri'

YCPATH = ENV['HOME'] + '/local/package/yui/yuicompressor-latest.jar'

SRC = ['vendor/jquery', 
       'vendor/jquery.json',
       'jqext',
       'annotator'].map { |x| "lib/#{x}.js" }

CSS = ['annotator'].map { |x| "lib/#{x}.css" }

task :default => :jspec

desc "Run JSpec tests"
task :jspec do
  sh "jspec run"
end

desc "Build packaged annotator"
task :package => ['pkg/jsannotate.min.js', 'pkg/jsannotate.min.css']

file 'pkg/jsannotate.min.js' => SRC do |t|
  yui_compressor(t.prerequisites, t.name)
end

file 'pkg/jsannotate.min.css' => CSS do |t|
  yui_compressor(t.prerequisites, t.name)
end

desc "Fetch latest versions of vendor files"
task :fetch_vendor do
  URLS = open('lib/vendor/URLS').readlines.map { |x| x.split ': ' }
  URLS.each do |(fname, url)|
    js = open(url).read
    File.open('lib/vendor/' + fname, 'w') { |f| f.write(js) }
    puts "Fetched #{url} for #{fname}"
  end
end

def yui_compressor(srclist, outfile)
  open(outfile, 'w') do |f|
    srclist.each do |src|
      f.write(open(src).read)
      puts "Wrote #{src} to #{outfile}"
    end
  end
  sh "java -jar #{YCPATH} -o #{outfile} #{outfile}"
  puts "Compressed #{outfile}"
end
