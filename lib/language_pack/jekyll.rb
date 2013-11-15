require "language_pack"
require "language_pack/rack"

# Jekyll Language Pack.
class LanguagePack::Jekyll < LanguagePack::Rack

  # detects if this is a Jekyll app
  # @return [Boolean] true if it's a Jekyll app
  def self.use?
    instrument "jekyll.use" do
      gemfile_lock? && LanguagePack::Ruby.gem_version('jekyll')
    end
  end

  def name
    "Ruby/Jekyll"
  end

  def compile
    instrument "jekyll.compile" do
      super
      run_site_precompile_task
    end
  end

  def run_site_precompile_task
    instrument "jekyll.run_site_precompile_task" do
      log("site_precompile") do
        topic("Jekyll site precompiling")
        puts "Running: bundle exec jekyll build"
        require 'benchmark'
        time = Benchmark.realtime { pipe("env PATH=$PATH:bin bundle exec jekyll build 2>&1 > /dev/null") }

        if $?.success?
          log "jekyll_build", :status => "success"
          puts "Site precompilation completed (#{"%.2f" % time}s)"
        else
          log "jekyll_build", :status => "failure"
          error "Precompiling site failed."
        end
      end
    end
  end
end
