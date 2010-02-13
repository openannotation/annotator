require 'open-uri'

YCPATH = ENV['HOME'] + '/local/package/yui/yuicompressor-latest.jar'

SRC = ['vendor/jquery.pluginfactory',
       'vendor/jquery.sji',
       'vendor/jquery.json',
       'extensions',
       'annotator',
       'annotation_store'].map { |x| "src/#{x}.js" }

CSS = ['annotator'].map { |x| "src/#{x}.css" }

task :default => :jspec

desc "Run JSpec tests"
task :jspec do
  sh "jspec run"
end

desc "Build packaged annotator"
task :package => ['pkg/annotator.min.js', 'pkg/annotator.min.css'] do 
  sh "cp -Rf src/img pkg/img"
end

file 'pkg/annotator.min.js' => SRC do |t|
  yui_compressor(t.prerequisites, t.name)
end

file 'pkg/annotator.min.css' => CSS do |t|
  yui_compressor(t.prerequisites, t.name)
end

desc "Make a release tag"
task :release => :package do |t|
  abort "Specify a tag: `TAG=0.1 rake release`" unless ENV['TAG']
  tag = ENV['TAG'].strip
  sh "git add -f pkg/*"
  tree = `git write-tree`
  commit = `echo 'Annotator release #{tag}' | git commit-tree #{tree}`
  sh "git tag #{tag} #{commit}"
  sh "git reset HEAD pkg/"
  sh "rm -Rf pkg/*"
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
