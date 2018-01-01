require "./spec_helper"

module M3U8
  describe SessionDataItem do

    describe "initialize" do
      options = {
        data_id: "com.test.movie.title",
        value: "Test",
        uri: "http://test",
        language: "en"
      }
      expected = %(#EXT-X-SESSION-DATA:DATA-ID="com.test.movie.title",VALUE="Test",URI="http://test",LANGUAGE="en")

      pending "hash" do
        SessionDataItem.new(options.to_h).to_s.should eq expected
      end

      it "namedtuple" do
        SessionDataItem.new(options).to_s.should eq expected
      end

      it "hash like" do
        SessionDataItem.new(**options).to_s.should eq expected
      end
    end

    {
      {
        {
          data_id: "com.test.movie.title",
          value: "Test",
          uri: "http://test",
          language: "en"
        },
        %(#EXT-X-SESSION-DATA:DATA-ID="com.test.movie.title",VALUE="Test",URI="http://test",LANGUAGE="en")
      },
      {
        {
          data_id: "com.test.movie.title",
          value: "Test",
          language: "en"
        },
        %(#EXT-X-SESSION-DATA:DATA-ID="com.test.movie.title",VALUE="Test",LANGUAGE="en")
      },
      {
        {
          data_id: "com.test.movie.title",
          uri: "http://test",
          language: "en"
        },
        %(#EXT-X-SESSION-DATA:DATA-ID="com.test.movie.title",URI="http://test",LANGUAGE="en")
      }
    }.each do |(params, format)|
      item = SessionDataItem.new(params)

      describe "initialize" do
        it "data_id" do
          item.data_id.should eq params[:data_id]
        end

        it "value" do
          item.value.should eq params[:value]?
        end

        it "uri" do
          item.uri.should eq params[:uri]?
        end
        
        it "language" do
          item.language.should eq params[:language]?
        end
      end

      it "to_s" do
        item.to_s.should eq format
      end
    end

    # it "should parse m3u8 format into instance" do
    #   format = %(#EXT-X-SESSION-DATA:DATA-ID="com.test.movie.title",) +
    #     %(VALUE="Test",LANGUAGE="en")
    #   item = SessionDataItem.parse format
    #   item.data_id.should eq "com.test.movie.title"
    #   item.value.should eq "Test"
    #   item.uri.should be_nil
    #   item.language.should eq "en"

    #   format = %(#EXT-X-SESSION-DATA:DATA-ID="com.test.movie.title",) +
    #     %(URI="http://test",LANGUAGE="en")
    #   item = SessionDataItem.parse format
    #   item.data_id.should eq "com.test.movie.title"
    #   item.value.should be_nil
    #   item.uri.should eq "http://test"
    #   item.language.should eq "en"
    # end
  end
end
