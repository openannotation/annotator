desc "Make a release tag"
task :release do |t|
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
