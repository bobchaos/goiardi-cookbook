# Installs and configures schob, the Shovey client
# Shovey's like Chef Push Jobs, but based on Hashicorp's Serf
property :instance_name, String, name_property: true
property :instance_path, String, default: '/usr/sbin'
property :version, String, default: 'latest'
property :bin_url, [String, NilClass], default: nil
property :user, String, name_property: true
property :group, String, name_property: true
property :goiardi_endpoint, String, required: true
property :conf, Hash, default: {}
property :whitelist, Hash, default: { whitelist: { 'chef-client': 'chef-client', 'cinc-client': 'cinc-client' } }
property :server_public_key, String, required: true
property :manage_conf, [TrueClass, FalseClass], default: true
property :manage_systemd_service, [TrueClass, FalseClass], default: true
property :options, [String, NilClass], default: nil
property :serf_unit_name, String, default: 'serf'

default_action :install

action :install do
  group new_resource.group do
    comment "Generated by #{Chef::Dist::PRODUCT} for #{new_resource.instance_name}"
    append true
    system true
    action :create
  end

  user new_resource.user do
    comment "Generated by #{Chef::Dist::PRODUCT} for #{new_resource.instance_name}"
    gid new_resource.group
    shell '/sbin/nologin'
    system true
    action :create
  end

  all_dirs.each do |dir|
    directory dir do
      owner new_resource.user
      group new_resource.group
      mode '0750'
      recursive true
      action :create
    end
  end

  remote_file bin_path do
    # Using node attributes in resources is often considered poor form
    # But these are automatic attributes and I have faith in ohai!
    source new_resource.bin_url || release_by_platform_url('ctdk/schob', node['os'], system_arch, new_resource.version)
    owner new_resource.user
    group new_resource.group
    mode '0755'
  end

  # Schob won't start without it's own private key
  openssl_rsa_private_key "#{conf_dir}/#{new_resource.instance_name}.pem" do
    group new_resource.group
    owner new_resource.user
    sensitive true
  end

  openssl_rsa_public_key "#{conf_dir}/#{new_resource.instance_name}.pub" do
    group new_resource.group
    owner new_resource.user
    private_key_path "#{conf_dir}/#{new_resource.instance_name}.pem"
    sensitive true
  end

  # The server's pub key
  file "#{conf_dir}/shovey.pub" do
    owner new_resource.user
    group new_resource.group
    mode '0644'
    content new_resource.server_public_key
    action :create
  end

  file "#{conf_dir}/#{new_resource.instance_name}_whitelist.json" do
    owner new_resource.user
    group new_resource.group
    mode '0640'
    content Chef::JSONCompat.to_json_pretty(new_resource.whitelist)
    action :create
  end

  if new_resource.manage_conf
    template "/etc/#{new_resource.instance_name}/#{new_resource.instance_name}.conf" do
      source 'schob.conf.erb'
      cookbook 'goiardi'
      owner new_resource.user
      group new_resource.group
      mode '0644'
      variables(conf: merged_conf.compact)
      action :create
    end
  end

  if new_resource.manage_systemd_service
    systemd_unit "#{new_resource.instance_name}.service" do
      content <<-EOU.gsub(/^\s+/, '')
      [Unit]
      Description=Shovey client to receive jobs from a Goiardi server
      After=network.target #{new_resource.serf_unit_name}.service
      Requires=#{new_resource.serf_unit_name}.service

      [Service]
      Type=exec
      User=#{new_resource.user}
      PIDFile=/var/lock/#{new_resource.instance_name}.pid
      ExecStart=#{new_resource.instance_path}/#{new_resource.instance_name} #{schob_options}
      Restart=On-failure

      [Install]
      WantedBy=multi-user.target
      EOU
      action [:create, :enable, :start]
      subscribes :restart, "template[#{conf_dir}/#{new_resource.instance_name}.conf]", :delayed
      subscribes :restart, "remote_file[#{bin_path}]", :delayed
    end
  end
end

action :remove do
  if new_resource.manage_systemd_service
    systemd_unit "#{new_resource.instance_name}.service" do
      action [:stop, :disable, :delete]
    end
  end

  file bin_path do
    action :delete
  end

  file "#{conf_dir}/#{new_resource.instance_name}.conf" do
    action :delete
  end

  all_dirs.each do |dir|
    directory dir do
      recursive true
      action :delete
    end
  end

  user new_resource.user do
    action :remove
  end

  group new_resource.group do
    action :remove
  end
end

action_class do  
  require 'chef/dist'
  # Generic helpers, those that do not rely directly on resource properties or ohai data
  include Goiardi::Helpers

  # Resource specific helper methods
  def schob_options
    new_resource.options ? new_resource.options : "-c #{conf_dir}/#{new_resource.instance_name}.conf"
  end

  def conf_dir
    "/etc/#{new_resource.instance_name}"
  end

  def all_dirs
    dirs = [
      conf_dir,
    ]
    %w(log-file key-file sign-pub-key whitelist queue-save-file).each do |f|
      dirs.push(::File.dirname(merged_conf[f.to_sym])) if merged_conf[f.to_sym]
    end
    clean_directories(dirs.compact.uniq, new_resource.instance_name)
  end

  def bin_path
    "#{new_resource.instance_path}/#{new_resource.instance_name}"
  end

  def system_arch
    node['kernel']['machine'] == 'x86_64' ? 'amd64' : node['kernel']['machine']
  end

  def merged_conf
    {
      'log-file': "/var/log/#{new_resource.instance_name}/#{new_resource.instance_name}.log",
      syslog: false,
      endpoint: new_resource.goiardi_endpoint,
      'node-name': node['fqdn'],
      'key-file': "#{conf_dir}/#{new_resource.instance_name}.pem",
      'sign-pub-key': "#{conf_dir}/shovey.pub",
      whitelist: "#{conf_dir}/#{new_resource.instance_name}_whitelist.json",
      'queue-save-file': "/var/lib/#{new_resource.instance_name}/queue_save_file",
    }.merge(new_resource.conf.to_h).compact
  end
end
