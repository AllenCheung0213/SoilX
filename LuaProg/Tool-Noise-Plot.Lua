
function plot_histogram(A, analysis, time_dom) 

	x, y = M.hist(A, 64)
	
	if time_dom then
		hist = plot("HIST_TIME", filename .. " HIST(".. analysis ..") - Time Dom", x, V.norm(y), "Histogram" )
		savename = params.file_dir .. "/" .. fname_no_ext .. "_hist_".. analysis .. "_time_dom.cha" 
	else
		hist = plot("HIST_FREQ", filename .. " HIST(".. analysis ..") - Freq Dom", x, V.norm(y), "Histogram" )
		savename = params.file_dir .. "/" .. fname_no_ext .. "_hist_".. analysis .. "_freq_dom.cha"
	end
	
	if window_manager.find(hist) then
		chart.set_xlabel(hist, analysis)
		chart.set_ylabel(hist, "Relative Ocurrence")
	end
	
	return hist, savename
end

-------------------------------------------

function plot_image(A, tape, analysis, time_dom)

	if time_dom then
		p = surface("IMAGE_TIME", filename .. " IMG(" .. analysis .. ") - Time Dom")
		savename = params.file_dir .. "/" .. fname_no_ext .. "_img_" .. analysis .. "_time_dom.sfc" 
	else
		p = surface("IMAGE_FREQ", filename .. " IMG(" .. analysis .. ") - Freq Dom")
		savename = params.file_dir .. "/" .. fname_no_ext .. "_img_" .. analysis .. "_freq_dom.sfc" 
	end
	
	surface.set(p, M.transpose(A), true)
	
	if F0 == F1 then
		forms.message("warning: start and stop frequencies are the same")
	end

	local T0 = tape[1].TIMESTAMP
	local T1 = tape[#tape].TIMESTAMP
	
	if time_dom then
		surface.set_scale(p, 0, time_end, T0, T1)
		surface.set_xlabel(p, "Time (nsec)")
		surface.set_title1(p, analysis .. " - Time Dom" )
	else
		surface.set_scale(p, F0, F1, T0, T1)
		surface.set_xlabel(p, "Frequency (MHz)")
		surface.set_title1(p, analysis .. " - Freq Dom" )
	end

	surface.set_title2(p, full_filename)
	surface.set_ylabel(p, "Time (sec)")
	surface.update(p)
	
	return p, savename
end

-------------------------------------------

function plot_chart(analysis, x_points, noise, x_label, time_dom)

	if time_dom then
		W1 = chart("SCALAR_TIME", filename .. " " .. analysis .. " - Time Dom", FL_CHART_WINDOW)
		savename = params.file_dir .. "/" .. fname_no_ext .. "_scal_".. analysis .. "_time_dom.cha" 
	else
		W1 = chart("SCALAR_FREQ", filename .. " " .. analysis .. " - Freq Dom", FL_CHART_WINDOW)
		savename = params.file_dir .. "/" .. fname_no_ext .. "_scal_".. analysis .. "_freq_dom.cha" 
	end
	
	if window_manager.find(W1) then
		-- chart.clear(W1)
		chart.add(W1, x_points, noise, "Noise - " .. analysis)
		chart.set_xlabel(W1, x_label)
		chart.set_ylabel(W1, "Noise amplitude")
		if params.log_scale and time_dom then
			chart.set_property(W1, LINE, LOG)
		else
			chart.set_property(W1, LINE)
		end
		chart.update(W1)
	end
	
	return W1, savename
end