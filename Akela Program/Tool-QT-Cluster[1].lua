-- Version 0.1, 02/23/10

L = require("Util-Lua")
P = require("Util-plot")

V = vector
M = matrix

C = complex

CV = complex_vector
CM = complex_matrix

-- Used to take a coordinate out of consideration
MAX_VALUE = 99999

maxDia = 3
minElements = 3

detectPeaks = CV { 
	C(2, 2),
	C(2, 3),
	C(-2, 2),
	C(-2, 3),
	C(-3, 2),
	C(-3, 3),
	C(2.5, 2),
	C(2.5, 3),
	C(99, 99),
	C(3, 2),
	C(3, 3),
	C(3.5, 2),
	C(3.5, 3),
	C(10, 10),
	C(10, 11),
	C(11, 10),
	C(50, 50),
	C(-2, 0),
	C(0, 2),
	C(0, 0),
	C(2, 0),
	C(1, -2),
	C(-1, -2),
	C(0, 0),
	C(17.2, 0),
	C(8.6, 14.8956369)
	}

function InitCluster (coor, index)
	local cluster = {
		coors = CV(1, coor),
		indexNums = V(1, index),
		centroid = C(),
		dia = 0
	}
	
	return cluster
end

function CalcDist (coor1, coor2) return C.abs(coor1 - coor2) end

function CalcCentroid (coors)
	local centroid = C()
	
	centroid[1] = V.avg(CV.real(coors))
	centroid[2] = V.avg(CV.imag(coors))

	return centroid
end

function CalcDia (coors)
	local maxDist = 0
	
	for i = 1, #coors do
		for j = i + 1, #coors do
			local dist = CalcDist(coors[i], coors[j])
			if (dist > maxDist) then
				maxDist = dist
			end
		end
	end

	return maxDist
end

function AddCoor (cluster, coor, index)
	local newClus = cluster

	CV.append(newClus.coors, coor)
	V.append(newClus.indexNums, index)
	newClus.dia = CalcDia(newClus.coors)
	
	if (newClus.dia > maxDia) then
		return cluster, false
	else
		return newClus, true
	end
end

function FindClusters (coors)
	local clusters = {}

	for i = 1, #coors do
		local cluster = InitCluster(coors[i], i)
		
		local dist = coors - coors[i]
		local distMag = CV.abs(dist)
		distMag[i] = MAX_VALUE
		
		local findNextPair = true
		while (findNextPair) do
			local minValue, minIndex = vector.min(distMag)
			if (minValue <= maxDia) then
				cluster, findNextPair = AddCoor(cluster, coors[minIndex], minIndex)
				distMag[minIndex] = MAX_VALUE
			else
				findNextPair = false
			end
		end
		
		table.insert(clusters, cluster)	
	end
	
	return clusters
end

peaks = CV(detectPeaks)
foundClusters = {}
findClusters = true

while (findClusters) do
	print("\nRemaining Peak Coordinates:")
	L.display(peaks)

	local clusters = FindClusters(peaks)

	local maxCluster = {
		size = 0,
		keyIndex = 0
	}

	for k,v in pairs(clusters) do
		if (#clusters[k].indexNums > maxCluster.size) then
			maxCluster.size = #clusters[k].indexNums
			maxCluster.keyIndex = k
		end
	end

	if (maxCluster.size >= minElements) then
		table.insert(foundClusters, clusters[maxCluster.keyIndex])

		if (#peaks - #clusters[maxCluster.keyIndex].indexNums >= minElements) then
			indices = V(#peaks, 1, 1)
			for i = 1, #clusters[maxCluster.keyIndex].indexNums do
				indices[clusters[maxCluster.keyIndex].indexNums[i]] = 0
			end
			indices = V.slice(V.sort(indices), #clusters[maxCluster.keyIndex].indexNums + 1)
			peaks = peaks[indices]
		else
			findClusters = false
		end
	else
		findClusters = false
	end
end

print("\n-------------------------")
print("Finished Finding Clusters")
print("-------------------------")

numClusters = 0
for k,v in pairs(foundClusters) do
	foundClusters[k].centroid = CalcCentroid(foundClusters[k].coors)
	
	print("\nCluster " .. k .. " -")
	print("\nSize:", #foundClusters[k].coors)
	print("Diameter:", foundClusters[k].dia)
	print("Centroid:", foundClusters[k].centroid)
	print("Element Coordinates:")
	L.display(foundClusters[k].coors)

	numClusters = numClusters + 1
end

if (numClusters == 0) then
	print("\nNo Clusters Found")
end

