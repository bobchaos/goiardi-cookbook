%w(goiardi schob serf).each do |srv|
  describe file("/usr/sbin/#{srv}") do
    it { should_not exist }
  end

  describe service(srv) do
    it { should_not be_installed }
    it { should_not be_running }
    it { should_not be_enabled }
  end

  describe directory("/etc/#{srv}") do
    it { should_not exist }
  end

  describe user(srv) do
    it { should_not exist }
  end

  describe group(srv) do
    it { should_not exist }
  end
end

['/var/lib/goiardi', '/var/log/goiardi', '/var/log/schob'].each do |dir|
  describe directory(dir) do
    it { should_not exist }
  end
end
