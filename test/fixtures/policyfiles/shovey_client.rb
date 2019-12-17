# A name that describes what the system you're building with Chef does.
name 'test_goiardi_default'

# Where to find external cookbooks:
default_source :supermarket

# run_list: chef-client will run these recipes in the order specified.
run_list 'test::shovey_client'

# Specify a custom source for a single cookbook:
cookbook 'goiardi', path: '../../../'
cookbook 'test', path: '../cookbooks/test'
