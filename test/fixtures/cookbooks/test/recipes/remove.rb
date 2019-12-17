include_recipe 'goiardi::default'

goiardi_install 'goiardi-remove' do
  instance_name 'goiardi'
  action :remove
end

goiardi_schob 'schob-remove' do
  instance_name 'schob'
  goiardi_endpoint 'does it really matter now?'
  action :remove
end

goiardi_serf 'serf-remove' do
  instance_name 'serf'
  action :remove
end
