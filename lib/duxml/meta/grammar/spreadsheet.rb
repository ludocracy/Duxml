module Duxml
  module Spreadsheet
    private
  # @param path [String] spreadsheet file
    def sheet_to_xml(path)
      doc = Doc.new(File.basename(path)+'.xml')
      doc << Grammar.xml
      worksheet = RubyXL::Parser.parse(spreadsheet)[0]
      attr_val_rule_hash = {}
      worksheet.each_with_index do |row, index|
        next if index == 0
        break if row[3].nil? || row[4].nil?
        element_name = row[3].value
        statement_str = row[4].value
        ary = [ChildrenRule.new(element_name, statement_str)]
        attribute_rules = row[5].value.split(/\n/)
        attribute_rules.each_with_index do |rule, i|
          next if i == 0 or rule.empty?
          attr_name, value_expr, attr_req = *rule.split
          ary << AttributesRule.new(element_name, attr_name, attr_req)
          unless attr_val_rule_hash[attr_name]
            ary << ValueRule.new(attr_name, value_expr)
            attr_val_rule_hash[attr_name] = true
          end
        end # attribute_rules.each_with_index
        ary.each do |rule|
          doc.grammar << rule
        end
      end # worksheet.each_with_index
      doc
    end
  end
end