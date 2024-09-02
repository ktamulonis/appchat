class AppchatFunction < ApplicationRecord
  has_many :function_parameters, dependent: :destroy

  def to_prompt_hash
    {
      name: name,
      description: description,
      class_name: class_name,
      parameters: function_parameters.each_with_object({}) do |param, hash|
        hash[param.name] = param.example_value
      end
    }
  end

  def self.all_to_prompt_json
    all.includes(:function_parameters).map(&:to_prompt_hash).to_json
  end
end
