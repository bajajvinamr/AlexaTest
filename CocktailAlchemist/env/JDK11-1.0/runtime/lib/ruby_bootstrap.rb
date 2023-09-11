# ruby_bootstrap.rb: Bootstrapper to emulate Amazon-specific ruby patches
# This is a generated file used for cross-platform emulation in BrazilCLI 2.0.
# DO NOT DELETE.

# Set the $ENVROOT global variable from the environment
# Emulates https://code.amazon.com/packages/Ruby21x/blobs/mainline/--/patches/ruby-envroot.diff
$ENVROOT = ENV['ENVROOT']

require "rbconfig"
arch = RbConfig::CONFIG['sitearch']

# Copied from amazon/brazil/cli/environment/ruby_helper.rb
RUBY_2_VERSIONS = ["2.1", "2.3", "2.4", "2.5", "2.7"].freeze

# Set up RbConfig, $LOAD_PATH and Gem.dir config values for the various ruby
# variants.
#
# The ordering of items in :config does not matter, but the ordering of
# :load_paths is intentional and matches the actual values obtained from within
# a ruby installation.
#
# The omission of arch-specific library directories from the load path is also
# intentional; we don't want to inadvertently load any native RHEL-only
# extensions from the environment root while running a cross-platform ruby
# interpreter.
#
variants = {
  "ruby1.9" => {
    config: {
      prefix: "",
      sitelibdir: "ruby1.9/site_ruby/1.9.1",
      sitearchdir: "ruby1.9/site_ruby/1.9.1/#{arch}",
    },
    load_paths: [
      "ruby1.9/site_ruby/1.9.1",
      "ruby1.9/site_ruby",
      "ruby1.9/1.9.1",
    ],
    gemdir: "ruby1.9/gems/1.9.1",
  },

  "jruby1.7" => {
    config: {
      prefix: "",
      sitelibdir: "jruby1.7.x/ruby/1.9/site_ruby",
      sitearchdir: "jruby1.7.x/ruby/1.9/site_ruby",
    },
    load_paths: [
      "jruby1.7.x/ruby/1.9/site_ruby",
      "jruby1.7.x/ruby/shared",
      "jruby1.7.x/ruby/1.9",
    ],
    gemdir: "jruby1.7.x/ruby/gems/shared",
  },
}.merge(
  RUBY_2_VERSIONS.each_with_object({}) do |version, ruby2_variants|
    ruby2_variants["ruby#{version}"] =
      {
        config: {
          prefix: "ruby#{version}.x",
          sitelibdir: "ruby#{version}.x/lib/ruby/site_ruby/#{version}.0",
          sitearchdir: "ruby#{version}.x/lib/ruby/site_ruby/#{version}.0/#{arch}",
        },
        load_paths: [
          "ruby#{version}.x/lib/ruby/site_ruby/#{version}.0",
          "ruby#{version}.x/lib/ruby/site_ruby",
          "ruby#{version}.x/lib/ruby/#{version}.0",
        ],
        gemdir: "ruby#{version}.x/lib/ruby/gems/#{version}.0",
      }
  end,
)

identifier = "#{RbConfig::CONFIG['RUBY_BASE_NAME'] || 'ruby'}#{RbConfig::CONFIG['MAJOR']}.#{RbConfig::CONFIG['MINOR']}"
ruby = variants[identifier]

# Prepend the $ENVROOT-prefixed load paths to the current load path, so that we
# can find Brazil-built ruby libraries:
load_paths = ruby[:load_paths].map { |path| File.join($ENVROOT, path) }
$LOAD_PATH.unshift(*load_paths)

# Use the $ENVROOT-prefixed gem path as Gem.dir (GEM_HOME) so that we can find
# Brazil-built gems, but preserve the existing Gem.path so that we can find
# locally installed native gems:
require "rubygems"
full_gemdir = File.join($ENVROOT, ruby[:gemdir])
Gem.use_paths(full_gemdir, Gem.path)

# BrazilRake uses various RbConfig settings to figure out where to look
# for/produce artifacts:
#
#   'prefix': used to determine the location of the 'gem_bin' directory
#   'sitelibdir' and 'sitearchdir': used to determine the prefix into which to
#     produce artifacts (e.g. ruby2.1.x/lib/ruby/site_ruby/2.1.x)
#
config = ruby[:config]
config.each do |key, path|
  RbConfig::CONFIG[key.to_s] = File.join($ENVROOT, path)
end
