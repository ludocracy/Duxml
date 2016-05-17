# Copyright (c) 2016 Freescale Semiconductor Inc.

class Regexp
  class << self
    # @return [Regexp] C identifier e.g. ident_ifier0, excluding 'true' and 'false'
    def identifier
      /(?:(?!true|false))\b([a-zA-Z_][a-zA-Z0-9_]*)\b/
    end

    # @return [Regexp] XML NMTOKEN e.g xml:attribute, also-valid, CDATA
    def nmtoken
      /(?!\s)([a-zA-Z0-9_\-.:]*)(?!\s)/
    end

    # @return [Regexp] Ruby constant e.g. Constant, CONSTANT
    def constant
      /\b([A-Z][a-zA-Z0-9_]*)\b/
    end
  end
end