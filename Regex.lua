

Instance.properties = properties({
	{name="Input", type="Text"},
    {name="Expression", type="Text"},
    {name="Operation", type="Enum", elements={"Find", "Sub", "Count"}, onUpdate="onOperationUpdate"},
    {name="Options", type="PropertyGroup", items={
        {name="Substitution", type="Text", ui={visible=false}},
        {name="Limit", type="Int", range={min=1}},
    }},
    {name="Run", type="Action"},
    {name="onResult", type="Alert", args={
        input_text="[input_text]",
        result="[result]",
        result_num="[result_num]",
        total_results="[total_results]",
    }},
})

function Instance:onInit()
    self:onOperationUpdate()
end

function Instance:onOperationUpdate()

end