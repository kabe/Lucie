# = setup-harddisks �f�B�X�N��`�p���C�u����
#
# Lucie ���\�[�X�ݒ�t�@�C�� <code>/etc/lucie/partition.rb</code> �̐擪�ł��̃t�@�C����
# <code>require</code> ���邱�ƁB�ڂ����� <code>doc/example/partition.rb</code> ���Q�ƁB
#
# $Id$
#
# Author::   Yoshiaki Sakae (mailto:sakae@is.titech.ac.jp)
# Revision:: $Revision$
# License::  GPL2

require 'lucie/setup-harddisks/partition'

# ------------------------- Convenience methods.

def partition ( label, &block )
  return Lucie::SetupHarddisks::Partition.new( label, &block )
end


### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
