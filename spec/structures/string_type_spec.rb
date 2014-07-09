require 'awltool/structures/string_type'

module AwlTool
  module Structures
    describe StringType do
      it 'should unescape an escaped string' do
        expect(StringType.unescape "$$$'$L$l$R$r$P$p").to eq "$'\n\n\r\r\f\f"
      end

      it 'should escape an string' do
        expect(StringType.escape "$'\n\r\f").to eq "$$$'$L$R$P"
      end
    end
  end
end
