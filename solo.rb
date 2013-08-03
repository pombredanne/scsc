root = File.absolute_path(File.dirname(__FILE__))
file_cache_path root
cookbook_path [File.join(root, 'site-cookbooks'),
               File.join(root, 'cookbooks')]
role_path File.join(root, 'roles')
# data_bag_path File.join(root, 'data_bags')
# encrypted_data_bag_secret File.join(root, 'data_bag_key')
