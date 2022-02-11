function OnEvent(event, arg)
	--OutputLogMessage("event = %s, arg = %s\n", event, arg);
	
	--===================================================
	--
	--This script converts the M1-3 keys to FN keys, rather than toggle keys. I have named this MShift, as it emulates the functionality of GShift on Logitech's mice. It also converts the current M-key to an extra key, and adds back togglability via G-keys in any M-layer, or even while MShifted for the all 30 possible buttons in a layer to be re-mapped without worrying about losing access to M-layers.
	--
	--This script also adds the toggling M-layers to keys, and can be customized to allow for a single key to be mapped to enable MShift, and then from within MShift, to be toggled-on. For example purposes, the following G-keys are configured as such, where the format is Button[M-State]:
	--G24[M1, M2, M3] mapped to M2Shift
	--G9[M2] mapped to M2 Toggle
	--Current M-key mapped to LCtrl
	--(i.e.: M1[M1], M2[M2], M3[M3])
	--And all M-keys that are not the current M-state are now MShifts instead of toggles.
	--(i.e.: M2[M1], M3[M1], M1[M2], M3[M2], M1[M3], M2[M3])
	--To use this functionality (and allow the maximum number of buttons available in M1 by only having MShift mapped, and no "MToggle"), if - in M1 (or M3) - M2 is held, and then G9 is pressed, when M2 is released, M2 will stay toggled on.
	--This also allows for binding the current M-State's button to an additional key, essentially making it G30 (see next comment section for details)
	--
	--===================================================
	--
	--This is all that needs to be changed for assigning a keypress to the current M-state's M-key; e.g.: in M1, if M1 is pressed - an extra re-mappable button!
	--To map this, follow the syntax as defined in the Appendix A of https://douile.github.io/logitech-toggle-keys/APIDocs.pdf ; i.e.: keep the quotes for the keyname, or remove them for the scancode. e.g.:
	--MMap = 0x1d
	--
	MMap = "lctrl"
	--
	--To map the G-key to toggle between different M-states, you will have to edit the code after the following block of comments.
	--
	--===================================================
	--
	--G1-22 are labelled, G23 is the left thumb button, and G24 is the bottom thumb button.
	--When the joystick is not assigned as a joystick, the click is G25, then starting from Up, going clockwise, is G26-G29. Visually, this looks like:
	--
	--    Click       G25
	--      Up        G26
	--          Right G27
	--     Down       G28
	--Left            G29
	--
	--But I find it more useful in a top-down view of the joystick:
	--
	--      Up        G26
	--Left            G29
	--    Click       G25
	--          Right G27
	--     Down       G28
	--
	--===================================================
	--
	--Side note: if you have a Logitech mouse in addition to a device with M-layers (like the G13 and G15), you can map functions that are only available from either device onto the other, for example: mapping GShift onto the G22 key will allow you to hold down G22 with your left hand, and use a single finger on your right hand to press a key that is mapped in GShift.
	--
	--More specifically to my use case, with the mouse emulation the G13 offers, it enables horizontal scrolling to be mapped onto the G600 in Logitech Gaming Software. (G HUB does allow horizontal scrolling to be mapped natively, but G HUB doesn't support the G13.)
	--
	--===================================================
	--
	--Add toggling M-States back; MShift disables this functionality by default
	--Note: M-states act as if they are constantly held down, until a new M-state is assigned. This is why a separate variable, "MShift", in addition to "MKeyState", must be assigned. Without this additional variable to compare to, MShift would only work in one M-state. Additionally, this enables the possiblility of toggling M-states.
	if event == "G_PRESSED" then
		MShiftRevert = 1
		--OutputLogMessage("G_PRESSED!\n")
		MShift = GetMKeyState("lhc")
		--M1 Toggle
		if MShift == 1 then
			--G24
			if arg == 24 then
				--Toggle to M2
				MKeyState = 2
				SetMKeyState(MKeyState, "lhc")
			end
		--M2 Toggle
		elseif MShift == 2 then
			--G24
			if arg == 24 then
				--Toggle to M1
				MKeyState = 1
				SetMKeyState(MKeyState, "lhc")
			--Stay on M2
			elseif arg == 9 then
				--Ends MShift on this layer
				MKeyState = 2
			end
		--M3 Toggle
		elseif MShift == 3 then
			--G24
			if arg == 24 then
				--Toggle to M1
				MKeyState = 1
				SetMKeyState(MKeyState, "lhc")
			end
		end
	end
	
	--===================================================
	--The following code need not be edited, and is what converts M-keys into MShifts.
	--===================================================
	--More detailed code explanation
	--===================================================
	--When MShift is released, the M-key for the current locked state is quickly toggled. As a result, the MShiftRevert variable keeps track of when this happens, to ensure that whatever is mapped to current M-State is not triggered erroneously.
	--===================================================
	
	--Set variables on launch so everything works
	if event == "PROFILE_ACTIVATED" then
		--Store MKeyState in variable "MKeyState"
		MKeyState = GetMKeyState("lhc")
		--Don't ignore next M-Key activation
		MShiftRevert = 0
	end
	
	--Add Current-mode M-key as additional key
	if event == "M_PRESSED" then
		if arg == MKeyState then
			if MShiftRevert == 2 then
				MShiftRevert = 0
			end
			if MShiftRevert == 0 then
				--OutputLogMessage("M-Remap_PRESSED\n")
				PressKey(MMap)
			end
		end
	end
	
	--MShift; on release, revert to MKeyState [ignore current state]
	if event == "M_RELEASED" then
		--Ensures the binding to the current M-state M-key is not pressed when it is toggled or MShifted.
		if MShiftRevert == 2 then
			MShiftRevert = 0
		elseif MShiftRevert == 1 then
			MShiftRevert = 2
		end
		--M2-Shift
		if arg == MKeyState then
		--Add Current-mode M-key as additional key
		--Current M-key bind release
			if MShiftRevert == 0 then
				--OutputLogMessage("M-Remap_RELEASED\n")
				ReleaseKey(MMap)
			end
		else
			--Ignore next M-Key activation
			MShiftRevert = 1
			SetMKeyState(MKeyState, "lhc")
		end
	end
	
end