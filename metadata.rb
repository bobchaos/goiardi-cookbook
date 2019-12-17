name 'goiardi'
maintainer 'Marc Chamberland'
maintainer_email 'chamberland.marc@gmail.com'
license 'Apache-2.0'
description 'Installs/Configures Goiardi, the Go implementation of Chef Server'
version '1.0.0'
chef_version '>= 14.0'

%w(centos ubuntu debian amazon).each do |os|
  supports os
end

# issues_url 'https://github.com/<insert_org_here>/goiardi/issues'

# source_url 'https://github.com/<insert_org_here>/goiardi'
