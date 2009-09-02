require File.join( File.dirname( __FILE__ ), "..", "spec_helper" )


class ConfigurationUpdator
  describe Server do
    context "updating server repository" do
      it "should update server repository" do
        Configuration.stub!( :temporary_directory ).and_return( "/TMP" )

        scm = mock( "scm" ).as_null_object
        Scm.stub!( :new ).and_return( scm )
        scm.should_receive( :update ).with( "/TMP/config/REPOSITORY" )

        Server.new.update "REPOSITORY"
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
