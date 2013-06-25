depends "build-essential"
depends "git"

%w{ubuntu debian}.each do |os|
  supports os
end
