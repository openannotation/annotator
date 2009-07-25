here = File.dirname(__FILE__)

ENV["BLUE_RIDGE_PREFIX"] = File.join(here, 'vendor/blue-ridge')
ENV["BLUE_RIDGE_TESTS"] = File.join(here, 'spec')

load 'vendor/blue-ridge/tasks/javascript_testing_tasks.rake'

task :default => ["test:javascripts"]
