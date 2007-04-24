#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


# A Progress is the abstract base class used to derive a ProgressBar
# which provides a visual text-based representation of the progress of
# a long running operation.
#
# Progress �ϡ�ProgressBar ���������륢�֥��ȥ饯�ȥ١������饹�Ǥ���
# ProgressBar �ϡ�Ĺ���֤ˤ錄�����οʹԾ����򡢻��Ū�˥ƥ�����ɽ��
# ���ޤ���
#
class Progress
  VERSION = '0.6.3'.freeze


  # Returns a new Progress object.
  #
  # ������ Progress object ���֤��ޤ���
  # 
  def initialize
    @activity_mode = false
    @show_text = false
  end


  # Return a value indicating wheter activity mode is enabled.
  #
  # * _Returns_ : true if activity mode is enabled.
  #
  # �����ƥ��ӥƥ��⡼�ɤ�ͭ�����ɤ������֤��ޤ���
  #
  # * �֤��� : �����ƥ��ӥƥ��⡼�ɤ�ͭ���Ǥ���� true��
  # 
  def activity_mode?
    @activity_mode
  end


  # Sets a value indicating whether activity mode is enabled.
  #
  # * _enable_ : true if activity mode is enabled.
  # * _Returns_ : enable
  #
  # �����ƥ��ӥƥ��⡼�ɤ�ͭ����̵�����򥻥åȤ��ޤ���
  #
  # * _enable_ : �����ƥ��ӥƥ��⡼�ɤ�ͭ���ˤ���ΤǤ���� true��
  # * �֤��� : enable 
  #
  def activity_mode=( enable )
    raise TypeError unless is_bool?( enable )
    @activity_mode = enable
  end


  # Same as activity_mode=.
  #
  # * _enable_ : true if activity mode is enabled.
  # * _Returns_ : self
  #
  # activity_mode= ��Ʊ���Ǥ���
  #
  # * _enable_ : �����ƥ��ӥƥ��⡼�ɤ�ͭ���ˤ���ΤǤ���� true��
  # * �֤��� : self
  #
  def set_activity_mode( enable )
    raise TypeError unless is_bool?( enable )
    @activity_mode = enable
    self
  end


  # Return a value indicating wheter the progress is shown as text.
  #
  # * _Returns_ : true if the progress is shown as text.
  #
  # �ʹԾ�����ƥ����Ȥ�ɽ�����뤫�ɤ������֤��ޤ���
  #
  # * �֤��� : �ʹԾ�����ƥ����Ȥ�ɽ������ΤǤ���� true��
  #
  def show_text?
    @show_text
  end


  # Sets a value indicating whether the progress is shown as text.
  #
  # * _shown_ : true if the progress is shown as text.
  # * _Returns_ : shown
  #
  # �ʹԾ�����ƥ����Ȥ�ɽ�����뤫�ɤ����򥻥åȤ��ޤ���
  #
  # * _shown_ : �ʹԾ�����ƥ����Ȥ�ɽ������ΤǤ���� true��
  # * �֤��� : shown
  #
  def show_text=( shown )
    raise TypeError unless is_bool?( shown )
    @show_text = shown
  end


  # Same as show_text=.
  #
  # * _shown_ : true if the progress is shown as text.
  # * _Returns_ : shown
  #
  # show_text= ��Ʊ����
  #
  # * _shown_ : �ʹԾ�����ƥ����Ȥ�ɽ������ΤǤ���� true��
  # * �֤��� : shown
  #
  def set_show_text( shown )
    raise TypeError unless is_bool?( shown )
    @show_text = shown
  end


  private


  def is_bool?( bool )
    bool.is_a?( TrueClass ) or bool.is_a?( FalseClass )
  end
end


### Local variables:
### mode: Ruby
### coding: euc-jp-unix
### indent-tabs-mode: nil
### End:
