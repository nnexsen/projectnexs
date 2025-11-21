while task.wait(.5) do
	for i,v in pairs(workspace:GetChildren()) do
		if v.Name == "Step" then
			v.glass_tempered:WaitForChild("glass_panel").Color = Color3.new(0, 1, 0)
			local bad = v.glass_weak:FindFirstChild("glass_panel_weak")
			if bad then
				bad.Color = Color3.new(1, 0, 0)
			end
		end
	end
	print("Scanning Glass..")
end
