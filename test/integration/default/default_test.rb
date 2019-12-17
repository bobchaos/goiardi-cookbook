# InSpec test for recipe goiardi::default

# The InSpec reference, with examples and extensive documentation, can be
# found at https://www.inspec.io/docs/reference/resources/

describe user('goiardi') do
  it { should exist }
  its('group') { should eq 'goiardi' }
  its('shell') { should eq '/sbin/nologin' }
end

describe groups.where { name == 'goiardi' } do
  it { should exist }
end

describe file('/usr/sbin/goiardi') do
  it { should exist }
  its('owner') { should eq 'goiardi' }
  its('group') { should eq 'goiardi' }
  its('mode') { should cmp '0755' }
end

['/var/lib/goiardi/goiardi-lfs', '/var/log/goiardi', '/etc/goiardi'].each do |dir|
  describe directory(dir) do
    it { should exist }
    its('owner') { should eq 'goiardi' }
    its('group') { should eq 'goiardi' }
    its('mode') { should cmp '0750' }
  end
end

describe file('/etc/goiardi/goiardi.conf') do
  it { should exist }
  its('owner') { should eq 'goiardi' }
  its('group') { should eq 'goiardi' }
  its('mode') { should cmp '0644' }
  # verify a default value shows up
  its('content') { should match %r{conf-root = "\/etc\/goiardi"} }
  # verify a value overriden with `nil` in test recipe is suppressed
  its('content') { should_not match /disable-webui/ }
  # verify a value overriden with another value in the test recipe outputs the override.
  its('content') { should match /log-level = "info"/ }
  # Verify a value added to the defaults in the test recipe is correctly merged
  its('content') { should match /purge-sandboxes-after = "720h"/ }
  # verify required values for Shovey are present
  its('content') { should match /use-serf = true/ }
  its('content') { should match /use-shovey = true/ }
end

describe file('/var/log/goiardi/goiardi.log') do
  it { should exist }
  its('owner') { should eq 'goiardi' }
  its('group') { should eq 'goiardi' }
end

describe user('schob') do
  it { should exist }
  its('group') { should eq 'schob' }
  its('shell') { should eq '/sbin/nologin' }
end

describe groups.where { name == 'schob' } do
  it { should exist }
end

describe file('/usr/sbin/schob') do
  it { should exist }
  its('owner') { should eq 'schob' }
  its('group') { should eq 'schob' }
  its('mode') { should cmp '0755' }
end

['/var/log/schob', '/etc/schob'].each do |dir|
  describe directory(dir) do
    it { should exist }
    its('owner') { should eq 'schob' }
    its('group') { should eq 'schob' }
    its('mode') { should cmp '0750' }
  end
end

describe file('/etc/schob/schob.conf') do
  it { should exist }
  its('owner') { should eq 'schob' }
  its('group') { should eq 'schob' }
  its('mode') { should cmp '0644' }
end

describe file('/var/log/schob/schob.log') do
  it { should exist }
  its('owner') { should eq 'schob' }
  its('group') { should eq 'schob' }
end

%w(goiardi serf schob).each do |srv|
  describe user(srv) do
    it { should exist }
    its('group') { should eq srv }
    its('shell') { should eq '/sbin/nologin' }
  end

  describe groups.where { name == srv } do
    it { should exist }
  end

  describe file("/usr/sbin/#{srv}") do
    it { should exist }
    its('owner') { should eq srv }
    its('group') { should eq srv }
    its('mode') { should cmp '0755' }
  end

  describe service(srv) do
    it { should be_installed }
    it { should be_running }
    it { should be_enabled }
  end

  describe directory("/etc/#{srv}") do
    it { should exist }
    its('owner') { should eq srv }
    its('group') { should eq srv }
    its('mode') { should cmp '0750' }
  end
end

describe file('/etc/serf/serf.json') do
  it { should exist }
  its('owner') { should eq 'serf' }
  its('group') { should eq 'serf' }
  its('mode') { should cmp '0644' }
  its('content') { should match /log_level/ }
end

['/var/log/schob', '/etc/schob'].each do |dir|
  describe directory(dir) do
    it { should exist }
    its('owner') { should eq 'schob' }
    its('group') { should eq 'schob' }
    its('mode') { should cmp '0750' }
  end
end

describe file('/etc/schob/schob.conf') do
  it { should exist }
  its('owner') { should eq 'schob' }
  its('group') { should eq 'schob' }
  its('mode') { should cmp '0644' }
end

describe file('/var/log/schob/schob.log') do
  it { should exist }
  its('owner') { should eq 'schob' }
  its('group') { should eq 'schob' }
end

describe file('/etc/schob/schob_whitelist.json') do
  it { should exist }
  its('owner') { should eq 'schob' }
  its('group') { should eq 'schob' }
  its('content') { should match /"chef-client": "chef-client"/ }
  its('content') { should match /"cinc-client": "cinc-client"/ }
end

describe file('/etc/schob/shovey.pub') do
  it { should exist }
end
