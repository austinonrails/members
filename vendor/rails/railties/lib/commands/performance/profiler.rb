if ARGV.empty?
  $stderr.puts "Usage: ./script/performance/profiler 'Person.expensive_method(10)' [times]"
  exit(1)
end

# Keep the expensive require out of the profile.
$stderr.puts 'Loading Rails...'
require RAILS_ROOT + '/config/environment'

# Define a method to profile.
if ARGV[1] and ARGV[1].to_i > 1
  eval "def profile_me() #{ARGV[1]}.times { #{ARGV[0]} } end"
else
  eval "def profile_me() #{ARGV[0]} end"
end

# Use the ruby-prof extension if available.  Fall back to stdlib profiler.
begin
  require 'prof'
  $stderr.puts 'Using the ruby-prof extension.'
  Prof.clock_mode = Prof::GETTIMEOFDAY
  Prof.start
  profile_me
  results = Prof.stop
  require 'rubyprof_ext'
  Prof.print_profile(results, $stderr)
rescue LoadError
  require 'profiler'
  $stderr.puts 'Using the standard Ruby profiler.'
  Profiler__.start_profile
  profile_me
  Profiler__.stop_profile
  Profiler__.print_profile($stderr)
end
