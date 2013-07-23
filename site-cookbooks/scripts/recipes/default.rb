%w(scsc-update).each do |f|
  cookbook_file "/usr/bin/#{f}" do
    mode 0755
  end
end
