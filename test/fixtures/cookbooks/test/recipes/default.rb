user_defined_conf = {
  'log-level': 'info',
  'disable-webui': nil,
  'purge-sandboxes-after': '720h',
  'use-serf': true,
  'use-shovey': true,
}

goiardi_serf 'serf'

# Please don't distribute private keys in your cookbooks :O
# I'm doing it here for testing and example purposes only
# Ideally keys will come from a secret manager such as Hashicorp Vault.
cookbook_file '/etc/shovey.pem' do
  source 'snakeoil_key.pem'
  mode '0600'
  action :create_if_missing
end

# Public keys are another story
cookbook_file '/etc/shovey.pub' do
  source 'snakeoil_key.pub'
  mode '0644'
  action :create
end

goiardi_install 'goiardi' do
  # We're using the cookbook_file keys
  private_key_path '/etc/shovey.pem'
  conf user_defined_conf
end

goiardi_schob 'schob' do
  goiardi_endpoint '127.0.0.1:4545'
  server_public_key lazy { IO.read('/etc/shovey.pub') }
  # normally Schob uses the Chef client key to sign requests but
  # for the purpose of testing we feed it the same key as the server
end
