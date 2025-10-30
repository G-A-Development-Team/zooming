print( "Zooming version 0.1 Loading..." ) -- 🚀 Script startup message

-- 📸 Download a PNG image (scope overlay) from GitHub
local pngData = http.Get("https://github.com/G-A-Development-Team/zooming/blob/main/scope01.png?raw=true")

-- 🧩 Decode the PNG into usable RGBA data and store its dimensions
local imgRGBA, imgWidth, imgHeight = common.DecodePNG(pngData)

-- 🖼️ Create a texture from the decoded image data
local texture = draw.CreateTexture(imgRGBA, imgWidth, imgHeight)

-- 🧮 Get the screen resolution for later drawing operations
local scrW, scrH = draw.GetScreenSize()

-- ➗ Calculate the width of the black bars on each side (used when drawing the scope)
local sideW = (scrW-scrH)/2

-- 🎛️ Create a GUI reference to the "Camera" section under WORLD
-- This section controls visual camera-related settings (FOV, zoom, etc.)
local camera = gui.Reference("WORLD", "Camera")
local world = gui.Reference("WORLD")

-- 🧰 Create a group box in the GUI to hold all zoom-related controls
local zoom = gui.Groupbox( world, "Zooming", 15, 330, 350 )

-- 🎚️ Add a slider to control the default Field of View (FOV)
-- Parameters: parent, identifier, label, default, min, max, step
gui.Slider(zoom, "ga_defaultfov", "Default View FOV", 90, 51, 120, 1)

-- ⌨️ Add a keybind that toggles the zoom on and off
-- Default key (5) is usually the 'E' key
gui.Keybox(zoom, "ga_zoomkey", "Toggle Zoom Key", 5)

-- 🔭 Checkbox to toggle whether the scope overlay is displayed
gui.Checkbox(zoom, "ga_displayscope", "Show Scope", true)

-- ♻️ Button to manually refresh the scope image from GitHub
local refresh = gui.Button( zoom, "Refresh Scope Image", function()
        pngData = http.Get("https://github.com/G-A-Development-Team/zooming/blob/main/scope01.png?raw=true")
		imgRGBA, imgWidth, imgHeight = common.DecodePNG(pngData)
		texture = draw.CreateTexture(imgRGBA, imgWidth, imgHeight);
 end )


-- 🕹️ This callback runs every frame — great for handling input and real-time updates
callbacks.Register("Draw", "HotKeys", function()

    -- 🔘 Check if the zoom toggle key was just released
	if input.IsButtonReleased(tonumber(gui.GetValue("world.ga_zoomkey"))) then

        -- 🔍 If FOV is currently zoomed (50), restore default FOV — otherwise zoom in!
    	if tonumber(gui.GetValue("world.fov")) == 50 then
			gui.SetValue("world.fov", tonumber( gui.GetValue("world.ga_defaultfov"))) -- 🔁 Restore normal view
		else
			gui.SetValue("world.fov", 50) -- 🎯 Zoom in
		end
	end
end)




-- 🎨 Draw the scope overlay when zoomed in
callbacks.Register("Draw", "DrawScope", function()
	
	if not entities.GetLocalPlayer() then 
		gui.SetValue("world.fov", tonumber( gui.GetValue("world.ga_defaultfov"))) 
		return 
	end

	if not entities.GetLocalPlayer():IsAlive() then 
		gui.SetValue("world.fov", tonumber( gui.GetValue("world.ga_defaultfov"))) 
		return 
	end
	
	if entities.GetLocalPlayer():GetFieldBool( "m_bIsScoped" ) then 
		gui.SetValue("world.fov", tonumber( gui.GetValue("world.ga_defaultfov"))) 
		return 
	end
	
	 
	-- ✅ Only draw if zoomed (FOV = 50) and the "Show Scope" box is enabled
	if tonumber( gui.GetValue( "world.fov" ) ) == 50 and gui.GetValue( "world.ga_displayscope" ) then
		draw.SetTexture(texture);
		draw.FilledRect(scrW/2-scrH/2, 0, scrH+scrW/2-scrH/2, scrH); -- 🖼️ Draw the circular scope
		draw.Color( 0, 0, 0, 255 )
		draw.SetTexture( nil )
		draw.FilledRect( 0, 0, sideW, scrH ) -- 🕳️ Left black bar
		draw.FilledRect( sideW+scrH, 0, sideW+sideW+scrH, scrH ) -- 🕳️ Right black bar
	end

end )

-- 🔁 Reset the FOV whenever a new round starts
callbacks.Register("FireGameEvent", "CheckRoundStart", function( event )

	if event:GetName() == "round_start" then
		gui.SetValue("world.fov", tonumber( gui.GetValue("world.ga_defaultfov"))) -- 🧼 Reset FOV
	end

end )

-- 🧹 Clean up and unregister everything when the script unloads
callbacks.Register( "Unload", "UnloadScript", function()
	print( "Zooming Unloading..." ) -- ⚙️ Unloading message
	callbacks.Unregister( "Draw", "HotKeys" )
	callbacks.Unregister( "Draw", "DrawScope" )
	callbacks.Unregister( "FireGameEvent", "CheckRoundStart" )
	callbacks.Unregister( "Unload", "UnloadScript" )
	print( "Zooming Unloaded!" ) -- ✅ Confirm cleanup
end )

print( "Zooming version 0.1 Loaded!" ) -- 🎉 Script successfully loaded!
