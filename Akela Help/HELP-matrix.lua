-- construction
matrix() --> M[i][j]; i = [1], j = [1]
matrix(nrow) --> M[i][j]; i = [1,nrow], j = [1,1]
matrix(nrow, ncol) --> M[i][j]; i = [1..nrow], j = [1..ncol]
matrix(matrix) --> copy of matrix

-- IO
print(M) --> "matrix(nrow,ncol)"

-- assignment
M[i] = M
M[i][j] = N is not allowed!  No assignment will take place!
matrix.set(M, i, j, number) --> void

-- selection
M[i] --> vector
M[i][j] --> number
matrix.get(M, i, j) --> number
matrix.select(M, V, [true]) - M[i] s.t. V[i] == 1
matrix.select(M, V, false) - M[i] s.t. V[i] == 0

-- predicates
M1 == M2 -->BOOL  Note: Comparison is made element by element.
matrix.eqv(M1, M2) --> BOOL  Note: Same as M1 == M2.

-- size
matrix.dims() --> nrow, ncol
#M --> NROW

-- arithmetic
M <op> <exp> 
<exp> <op> M

	w\ <op> is any valid arthimetic binary operator 
	w\ <expr> evaluates to any numerical value or aggregate

	Note that the above operations are performed element by element.

M^N ->M
-M --> -M[i][j]

-- structural functions
matrix.append(M1, M2) --> modified M1 .. M2 by row
matrix.append(M1, V) --> modified M1 .. M2 by row

matrix.append1(M1, M2) --> modified M1 .. M2 by row
matrix.append1(M1, V) --> modified M1 .. M2 by row

matrix.append2(M1, M2) --> modified M1 .. M2 by column
matrix.append2(M1, V) --> modified M1 .. M2 by column

matrix.reverse(M) --> vector.reverse(M[i]) ..

matrix.shift(M, n) --> M s.t. M[j] = M[i] w\ j = i + nshift mod |M|
matrix.shift1(M, n) --> M s.t. M[j] = M[i] w\ j = i + nshift mod |M|
matrix.shift2(M, n) --> matrix.shift(M[i]) ..


matrix.slice(M, [s = 1], [f = #V]) --> M[s][j], ..., M[f][j]
matrix.slice1(M, [s = 1], [f = #V]) --> M[s][j], ..., M[f][j]
matrix.slice2(M, [s = 1], [f = #V]) --> M[i][s], ..., M[i][f]

  -- Note that negative slice parameters are referenced from end of matrix.

matrix.transpose(M) --> M[j][i]; i = [1..nrow], j = [1..ncol]

matrix.truncate(M, n) --> M[1][j], M[2-1][j], ..., M[n][j]
matrix.truncate1(M, n) --> M[1][j], M[2-1][j], ..., M[n][j]
matrix.truncate2(M, n) --> M[i][1], M[i][2-1], ..., M[i][n]

M1 .. M2 --> new CM

-- statistical functions
matrix.avg(M) --> V by column
matrix.min(M) --> V by column
matrix.max(M) --> V by column

matrix.global_min(M) --> VMIN, IMIN, JMIN
matrix.global_max(M) --> VMAX, IMAX, JMAX

matrix.hist(M) --> V, V
matrix.stats(M) --> min, max, avg, std

-- advanced functions
matrix.sum(M) --> V by column
matrix.prod(M) --> V by column

matrix.cumsum(M) --> V by column
matrix.cumprod(M) --> V by column

matrix.find(M, FUNC) --> M s.t. M[i] = FUNC(V[i])

matrix.rotate(M, angle) --> M
matrix.rotate(M, V) --> M

matrix.unwrap(M) --> M

-- standard library wrappers
matrix.abs(M) --> M
matrix.acos(M) --> M
matrix.asin(M) --> M
matrix.atan(M) --> M
matrix.atan2(M1, M2) --> M
matrix.cos(M) --> M
matrix.cosh(M) --> M
matrix.exp(M) --> M
matrix.log(M) --> M
matrix.log10(M) --> M
matrix.pow(M, n) --> M
matrix.sin(M) --> M
matrix.sinh(M) --> M
matrix.sqrt(M) --> M
matrix.tan(M) --> M
matrix.tanh(M) --> M

-- advanced IPP functions
matrix.ipp_erode(M) --> VOID
matrix.ipp_dilate(M) --> VOID
matrix.ipp_threshold(M, threshold) --> void
matrix.ipp_find_peaks(M, threshold) --> COMPLEX_VECTOR of (R, C) indexes unsorted)

-- conversion
matrix.to_vector(M) --> V