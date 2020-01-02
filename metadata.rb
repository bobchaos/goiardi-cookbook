name 'cinc-goiardi'
maintainer 'Cinc Project'
maintainer_email 'cookbooks@cinc.sh'
license 'Apache-2.0'
description 'Installs/Configures Goiardi, the Go implementation of Chef Server'
version '1.0.1'
chef_version '>= 14.0'

%w(centos ubuntu debian amazon).each do |os|
  supports os
end

issues_url 'https://gitlab.com/chamberland.marc/cinc-goiardi-cookbook/issues'

source_url 'https://gitlab.com/chamberland.marc/cinc-goiardi-cookbook'
