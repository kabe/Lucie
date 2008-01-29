# Partition configuration for Lucie

require 'lucie/setup-harddisks/config'


target = FileTest::exists?( '/dev/sda' ) ? '/dev/sda' : '/dev/hda'

partition 'root' do | p |
  p.slice = target
  p.kind = 'primary'
  p.fs = 'ext3'
  p.mount_point = '/'
  p.size = (128..256)
  p.bootable = true
  p.fstab_option << 'errors=remount-ro'
  p.dump_enabled = true
end

partition 'swap' do | p |
  p.slice = target
  p.kind = 'primary'
  p.fs = 'swap'
  p.mount_point = 'none'
  p.size = (256..512)
end

partition 'var' do | p |
  p.slice = target
  p.kind = 'logical'
  p.fs = 'reiserfs'
  p.mount_point = '/var'
  p.size = 256
end

partition 'usr' do | p |
  p.slice = target
  p.kind = 'logical'
  p.fs = 'reiserfs'
  p.mount_point = '/usr'
  p.size = (512..9999999)
end

partition 'home' do | p |
  p.slice = target
  p.kind = 'logical'
  p.fs = 'reiserfs'
  p.mount_point = '/home'
  p.size = 512
  p.fstab_option << 'nosuid'
end

#partition 'home' do | p |
#  p.slice = 'hda7'
#  p.mount_point = '/home'
#  p.preserve = true
#  p.fstab_option << 'nosuid'
#end
