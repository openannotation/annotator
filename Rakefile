SRC =         ['extensions',
               'console',
               'class',
               'range',
               'annotator',
               'editor',
               'viewer',
               'notification'].map { |x| "src/#{x}.coffee" }

SRC_PLUGINS = ['tags',
               'auth',
               'store',
               'markdown',
               'unsupported',
               'permissions'].map { |x| "src/plugin/#{x}.coffee" }

CSS = ['annotator'].map { |x| "css/#{x}.css" }

desc "Build packaged annotator (set MINIFY=false to skip compression of files)"
task :package => ['pkg/annotator.min.js', 'pkg/annotator.min.css', :plugins]

file 'pkg/annotator.min.js' => SRC do |t|
  coffee_concat(t.prerequisites, t.name)
  yui_compressor(t.name)
end

file 'pkg/annotator.min.css' => CSS do |t|
  concat(t.prerequisites, t.name)
  yui_compressor(t.name)
  data_uri_ify(t.name)
end

task :plugins => SRC_PLUGINS do |t|
  t.prerequisites.each do |plugin|
    plugin_name = File.basename(plugin, ".coffee")
    outfile = "pkg/annotator.#{plugin_name}.min.js"

    coffee_concat([plugin], outfile)
    yui_compressor(outfile)
  end
end

desc "Make a release tag"
task :release => :package do |t|
  abort "Specify a tag: `TAG=v0.0.1 rake release`" unless ENV['TAG']
  tag = ENV['TAG'].strip

  system "git diff-index --quiet --cached HEAD && git diff-files --quiet && git ls-files --others --exclude-standard"
  if $? != 0
    puts "Not creating release in dirty environment."
  else
    sh "git co master"
    sh "git add -f pkg/*"
    tree = `git write-tree`.strip
    parent = `git rev-parse master`.strip
    commit = `echo 'Annotator release #{tag}' | git commit-tree #{tree} -p #{parent}`
    sh "git tag #{tag} #{commit}"
    sh "git reset HEAD pkg/"
    sh "rm -Rf pkg/*"
  end
end

desc "Clobber package files"
task :clobber do
  rm 'pkg/annotator.min.js'
  rm 'pkg/annotator.min.css'
  SRC_PLUGINS.each do |p|
    rm "pkg/annotator.#{File.basename(p, ".coffee")}.min.js"
  end
end

def coffee_concat(srclist, outfile)
  sh "coffee -jp #{srclist.join ' '} > #{outfile}"
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
  unless ENV['MINIFY'] == 'false'
    begin
      require 'yui/compresso'
    rescue LoadError => e
      puts "`gem install yui-compressor` for minification (Error: #{e})"
    end

    return unless defined? YUI

    if file =~ /.js$/
      compressor = YUI::JavaScriptCompressor.new
    else
      compressor = YUI::CssCompressor.new
    end

    compressed = compressor.compress(open(file).read)
    open(file, 'w') { |f| f.write compressed }

    puts "Compressed #{file}"
  end
end

def data_uri_ify(file)
  lines = open(file, 'r').readlines.map do |line|
    line.gsub(/(url\(([^)]+)\.png\))/) do
      puts $1, $2
      b64 = `openssl enc -a -in src/#{$2}.png | tr -d "\n"`
      "url('data:image/png;base64,#{b64}')"
    end
  end

  open(file, 'w') do |f|
    f.puts lines.join
  end
end
