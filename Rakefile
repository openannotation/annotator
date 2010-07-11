require 'open-uri'

YCPATH = ENV['YCPATH'] ||
         ENV['HOME'] + '/local/package/yui/yuicompressor-latest.jar'

SRC = ['vendor/jquery.pluginfactory',
       'vendor/jquery.sji',
       'vendor/jquery.json',
       'extensions',
       'annotator',
       'plugins/store',
       'plugins/user'].map { |x| "src/#{x}.js" }

CSS = ['annotator'].map { |x| "src/#{x}.css" }

task :default => :jspec

desc "Run JSpec tests"
task :jspec do
  sh "jspec run"
end

desc "Build packaged annotator"
task :package => ['pkg/annotator.min.js', 'pkg/annotator.min.css']

file 'pkg/annotator.min.js' => SRC do |t|
  concat(t.prerequisites, t.name)
  yui_compressor(t.name)
end

file 'pkg/annotator.min.css' => CSS do |t|
  concat(t.prerequisites, t.name)
  data_uri_ify(t.name)
  yui_compressor(t.name)
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

desc "Clobber package files"
task :clobber do
  rm 'pkg/annotator.min.js'
  rm 'pkg/annotator.min.css'
end

def concat(srclist, outfile)
  open(outfile, 'w') do |f|
    srclist.each do |src|
      f.write(open(src).read)
      puts "Wrote #{src} to #{outfile}"
    end
  end
end

def yui_compressor(file)
  sh "java -jar #{YCPATH} -o #{file} #{file}"
  puts "Compressed #{file}"
end

def data_uri_ify(file)
  lines = open(file, 'r').readlines.map do |l|
    m = l.match(/(url\(([^)]+)\.png\))/)

    if m
      b64 = `openssl enc -a -in src/#{m[2]}.png | tr -d "\n"`
      l.sub(m[1], "url('data:image/png;base64,#{b64}')")
    else
      l
    end
  end

  open(file, 'w') do |f|
    f.puts lines.join
  end
end
