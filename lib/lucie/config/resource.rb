module Lucie
  module Config
    # ���٤ƤΥ꥽�������饹
    # * �ۥ��� (Host)
    # * �ۥ��ȥ��롼�� (HostGroup)
    # * �ѥå����������� (PackageServer)
    # * DHCP ������ (DHCPServer)
    # * ���󥹥ȡ��� (Installer)
    # �οƤȤʤ륯�饹��
    #
    # �ҤȤʤ�꥽�������饹�ϡ��ʲ��Υ��饹�ѿ������ɬ�פ�����
    # * ��Ͽ����Ƥ���꥽�������֥������ȤΥꥹ��: <code>@@list = []</code>
    # * ���ȥ�ӥ塼��̾�Υꥹ��: <code>@@required_attributes = []</code>
    # * ���٤ƤΥ��ȥ�ӥ塼��̾�ȥǥե�����ͤΥꥹ��: <code>@@attributes = []</code>
    # * ���ȥ�ӥ塼��̾����ǥե�����ͤؤΥޥåԥ�: <code>@@default_value = {}</code>
    #
    class Resource  
      # ------------------------- Convenience class methods.

      # ��Ͽ����Ƥ���꥽�����򥯥ꥢ����
      public
      def self.clear
        module_eval %-
          @@list.clear
        -
      end

      # °����̾�����֤�
      public
      def self.attribute_names
        module_eval %-
          @@attributes.map { |name, default| name }
        -
      end
      
      # <code>[°��, �ǥե������]</code> ��������֤�
      public
      def self.attribute_defaults
        module_eval %-
          @@attributes.dup
        -
      end
      
      # °�� <code>name</code> ���б�����ǥե�����ͤ��֤�
      public
      def self.default_value( name )
        module_eval %-
          @@default_value[:#{name}]
        -
      end
      
      # ɬ��°�����֤�
      public
      def self.required_attributes
        module_eval %-
          @@required_attributes.dup
        -
      end
      
      # °�� <code>name</code> ��ɬ��°���Ǥ��뤫�ɤ������֤�
      public
      def self.required_attribute?( name )
        module_eval %-
          @@required_attributes.include? :#{name}
        -
      end
      
      # ------------------------- Infrastructure class methods.

      # ��Ͽ����Ƥ���꥽������ <code>key</code> ��õ��
      public
      def self.[](key)
        module_eval %-
          @@list['#{key}']
        -
      end
      
      # ��Ͽ����Ƥ���꥽�������֤�
      public
      def self.list
        module_eval %-
          @@list
        -
      end
      
      # °�����������
      public
      def self.attribute( name, default=nil )
        if default.nil?
          module_eval %-
            if !@@attributes.assoc(name)
              @@attributes << [:#{name}, nil]
              @@default_value[:#{name}] = nil
            end
          -
        else
         module_eval %-
            @@attributes << [:#{name}, '#{default}']
            @@default_value[:#{name}] = '#{default}'
          -
        end
        attr_accessor name
      end
      
      # ɬ��°�����������
      public
      def self.required_attribute( *args )
        module_eval %-
          @@required_attributes << :#{args.first}
        -
        attribute( *args )
      end      
            
      # °������ˤϥ����������줿�Ȥ������̤�ư����׵᤹���Τ����롣
      # ���Υ᥽�åɤ�ư�������Ǥ��롣
      def self.overwrite_accessor(name, &block)
        remove_method name
        define_method(name, &block)
      end   
      
      # �������꥽�������֥������Ȥ��֤�
      public
      def initialize # :yield: self
        set_default_values        
        yield self if block_given?
        register
      end
      
      # �꥽������ʸ����ɽ�����֤�
      public
      def to_s
        if @alias
          return "#{@name} (#{@alias})"
        else
          return name
        end
      end
      
      # ���٤Ƥ�°���˥ǥե�����ͤ򥻥åȤ��롣
      # ���åȤϥ������å��᥽�åɤ��̤��ƹԤ��뤿�ᡢ�������å������ꤵ�줿
      # ���̤ʽ����⤢�碌�Ƽ¹Ԥ���롣�ޤ������줾��Υ��󥹥��󥹤����Ȥ���
      # �ȼ��ζ� Array ����Ĥ褦�ˡ��ǥե�����ͤΥ��ԡ���Ȥ���     
      private
      def set_default_values
        self.class.attribute_defaults.each do |attribute, default|
          self.send "#{attribute}=", copy_of(default)
        end
      end
      
      private
      def register
        self.class.list[name] = self
      end
      
      # ¨�Ͱʳ��ϥ��֥������Ȥ� dup ����
      private
      def copy_of(obj)
        case obj
        when Numeric, Symbol, true, false, nil then obj
        else obj.dup
        end
      end
    end
    
    class InvalidAttributeException < ::Exception; end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
