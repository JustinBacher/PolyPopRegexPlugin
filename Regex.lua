
Instance.properties = properties({
	{name="Text", type="Text"},
    {name="Operation", type="Enum", elements={"Find", "Findall", "Sub"}, onUpdate="onOperationUpdate"},
    {name="Options", type="PropertyGroup", items={
        {name="Expression", type="Text"},
        {name="Substitution", type="Text", ui={visible=false}},
        {name="ResultInterval", type="Real", units="Seconds", value=1, range={min=0}, ui={easing=5, step=0.1}},
    }, ui={expand=true}},
    {name="Run", type="Action"},
    {name="onResult", type="Alert", args={
        input_text="[input_text]",
        result="[result]",
        result_num="[result_num]",
    }},
    {name="onResultCount", type="Alert", args={count="[count]"}},
    {name="onNoResult", type="Alert"},
    {name="Info", type="Action"},
})

function Instance:sendMatch(match, num)
    self.properties.onResult:raise({
        input_text=self.properties.Text,
        result=match,
        result_num=num,
    })
end

function Instance:Find()
    local match = self.properties.Text:match(self.properties.Options.Expression)
    
    if match then
        self.properties.onResultCount:raise({result_num=1})
        self:sendMatch(match, 1)
    else
        self.properties.onNoResult:raise()
    end
end

function Instance:sendTimedMatch(getNextMatch, num)
    local nextMatch = getNextMatch()

    if nextMatch then
        count += 1
        self:sendMatch(nextMatch, num)
        getAnimator():createTimer(
            self,
            function() self:sendTimedMatch(getNextMatch, num + 1) end,
            Seconds(self.properties.Options.ResultInterval),
        )
    end
end

function Instance:Findall()
    local text = self.properties.Text
    local count = 0
    
    for _ in text:gmatch(self.properties.Options.Expression) do
        count += 1
    end

    if count > 0 then
        self.properties.onResultCount:raise({result_num=count})
        getAnimator():createTimer(
            self,
            function(), self:sendTimedMatch(text:gmatch(self.properties.Options.Expression), 1) end
        )
    else
        self.properties.onNoResult:raise()
    end
end

function Instance:Sub()
    local text = self.properties.Text

    self.properties.onResultCount:raise({result_num=1})
    self.properties.onResult:raise({
        input_text=text,
        result=text:gsub(self.properties.Options.Expression)
        result_num=1,
    })
end

Instance.ops = {
    Find = Instance.Find,
    Findall = Instance.Findall
    Sub = Instance.Sub,
}

function Instance:onInit()
    self:onOperationUpdate()
end

function Instance:onOperationUpdate()
    local op = self.properties.Operation
    getUI():setUIProperty({{obj=self.properties.Options:find("Substitution"), visible=op == "Sub"}})
    getUI():setUIProperty({{obj=self.properties.Options:find("ResultInterval"), visible=op == "Findall"}})
end

function Instance:Run()
    local op = self.ops[self.properties.Operation]
    
    if op then
        op(self)
    end
end

function Instance:Info()
    -- Show popup of how to use
end