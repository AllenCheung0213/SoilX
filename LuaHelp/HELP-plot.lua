plot(plot-list)
plot(type, plot-list) --> name
plot(type, name, plot-list) --> name

plot.append(name, plot-list) --> name

where plot-list is

	plot-line
	{plot-line}, {plot-line}, ...

where plot-line	

	vector, [vector], [title], [title]
	complex-vector, [title], [title]

plot.magnitude_frequency([plot-list]) --> name
plot.magnitude_time([plot-list]) --> name
plot.magnitude_time([plot-list]) --> name
plot.phase_frequency([plot-list]) --> name
plot.phase_time([plot-list]) --> name
