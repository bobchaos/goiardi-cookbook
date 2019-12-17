module Goiardi
  module Helpers
    require 'json'

    def release_by_platform_url(repo, platform, arch, version)
      asset = release_data(repo, version)['assets'].detect { |a| a['name'] == release_bin_name(repo, platform, arch, version) }
      raise 'Failed to locate asset' unless asset
      asset['browser_download_url']
    end

    def clean_directories(dirs, name)
      # crude but effective method to prevent chowning/deleting system directories
      dirs.reject { |d| !d.chomp('/').match(/#{name}/) }
    end

    def system_arch(arch)
      arch == 'x86_64' ? 'amd64' : arch
    end

    def serf_archive_name(platform, arch, version)
      ['serf', plain_version(version), platform, "#{arch}.zip"].join('_')
    end

    private

    def release_bin_name(repo, platform, arch, version)
      [repo.split('/').last, plain_version(expand_version(repo, version)), platform, arch].join('-')
    end

    def version_as_tag(repo, version)
      expanded = expand_version(repo, version)
      expanded.match(/^v/) ? expanded : "v#{expanded}"
    end

    def plain_version(version)
      version.start_with?('v') ? version.gsub(/^v/, '') : version
    end

    def expand_version(repo, version)
      if version == 'latest'
        return @latest_version if defined?(@latest_version)
        @latest_version = JSON.parse(Chef::HTTP.new('https://api.github.com').get("/repos/#{repo}/releases/latest"))['tag_name']
      else
        version
      end
    end

    def release_data(repo, version)
      return @release_data if defined?(@release_data)
      @release_data = JSON.parse(Chef::HTTP.new('https://api.github.com').get("/repos/#{repo}/releases/tags/#{version_as_tag(repo, version)}"))
    end
  end
end
