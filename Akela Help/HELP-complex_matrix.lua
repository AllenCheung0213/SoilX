-- construction
complex_matrix() --> CM[i][j]; i = [1], j = [1]
complex_matrix(nrow) --> CM[i][j]; i = [1,nrow], j = [1,1]
complex_matrix(nrow, ncol) --> CM[i][j]; i = [1..nrow], j = [1..ncol]
complex_matrix(complex_matrix) --> copy of complex_matrix

-- IO
print(CM) --> "complex_matrix(nrow,ncol)"

--assignment
CM[i] = complex_vector
CM[i][j] = C is not allowed!  No assignment will take place!
complex_matrix.set(CM, i, j, complex_number) --> void

-- selection
CM[i] --> complex_vector
CM[i][j] --> complex_number
complex_matrix.get(CM, i, j) --> complex_number
complex_matrix.select(CM, V, [true]) - CM[i] s.t. V[i] == 1
complex_matrix.select(CM, V, false) - CM[i] s.t. V[i] == 0

CM[V] --> new_CM[i] = CM[V[i]]
CM[C] --> CM[C[1], C[2]] 

-- predicates
CM1 == CM2 -->BOOL  Note: Comparison is made element by element.
complex_matrix.eqv(CM1, CM2) --> BOOL  Note: Same as M1 == M2.

-- size
complex_matrix.dims() --> nrow, ncol
#CM --> NROW

-- arithmetic
CM <op> <exp> 
<exp> <op> CM

	w\ <op> is any valid arthimetic binary operator 
	w\ <expr> evaluates to any numerical value or aggregate

	Note that the above operations are performed element by element.
	
CM^N -> CM
-CM --> -CM[i][j]

-- structural functions
complex_matrix.append(CM1,CM2) --> modified CM1 .. CM2

CM1 .. CM2 --> new CM

complex_matrix.reverse(M) --> complex_vector.reverse(M[i]) ..

complex_matrix.shift(CM, n) --> CM s.t. CM[j] = CM[i] w\ j = i + nshift mod |CM|
complex_matrix.shift1(CM, n) --> CM s.t. CM[j] = CM[i] w\ j = i + nshift mod |CM|
complex_matrix.shift2(CM, n) --> complex_vector.shift(CM[i]) ..

complex_matrix.exchange(M, n) --> complex_vector.exchange(M[i]) ..

complex_matrix.slice(M, [s = 1], [f = #V]) --> M[s][j], ..., M[f][j]
complex_matrix.slice1(M, [s = 1], [f = #V]) --> M[s][j], ..., M[f][j]
complex_matrix.slice2(M, [s = 1], [f = #V]) --> M[i][s], ..., M[i][f]

  -- Note that negative slice parameters are referenced from end of matrix.

complex_matrix.transpose(M) --> M[j][i]; i = [1..nrow], j = [1..ncol]
complex_matrix.truncate(M, n) --> M[1][j], M[2-1][j], ..., M[n][j]
complex_matrix.truncate1(M, n) --> M[1][j], M[2-1][j], ..., M[n][j]
complex_matrix.truncate2(M, n) --> M[i][1], M[i][2-1], ..., M[i][n]

-- statistical functions
complex_matrix.avg(CM) --> sum(CM) / #CM

-- advanced functions
complex_matrix.sum(CM) --> CM[1] + CM[2] + ...
complex_matrix.prod(CM) --> CM[1] * CM[2] * ... * CM[#CM]

complex_matrix.cumsum(CM) --> W s.t. W[i] = CM[1] + CM[2] + ... + CM[i]); i = [1..#CM]
complex_matrix.cumprod(CM) --> W s.t. W[i] = CM[1], CM[2], ... CM[i]); i = [1..#CM]

-- no zero fill
complex_matrix.fft(CM, [NFFT], [WINDOW = false], [REVERSE = true]) --> CM

-- zero fill	
complex_matrix.fft(CM, NFFT, F0, F1, [WINDOW = false], [REVERSE = true]) --> CM

	NOTE: NFFT = 2^N s.t. NFFT >= #CM

-- no zero fill or window capability
complex_matrix.fft1(CM, NFFT, [beg_row = 1], [end_row = height])
complex_matrix.fft2(CM, NFFT, [beg_col = 1], [end_col = width])

complex_matrix.ifft1(CM, NFFT, [beg_row = 1], [end_row = height])
complex_matrix.ifft2(CM, NFFT, [beg_col = 1], [end_col = width])

-- extended functions
complex_matrix.dec(CM) --> 20 * log10(abs(V))
complex_matrix.rotate(CM, angle) --> CM
complex_matrix.rotate(CM, V) --> CM
complex_matrix.unwrap(CM) --> M

-- standard library wrappers
complex_matrix.abs(CM) --> sqrt(Re^2 + Im^2)
complex_matrix.arg(CM) --> arctan2(Im, re)
complex_matrix.conj(CM) --> (Re, -Im)
complex_matrix.cos(CM) --> CM
complex_matrix.cosh(CM) --> CM
complex_matrix.exp(CM) --> CM
complex_matrix.imag(CM) --> M
complex_matrix.log(CM) --> CM
complex_matrix.log10(CM) --> CM
complex_matrix.norm(CM) --> Re^2 + Im^2
complex_matrix.pow(CM, n) --> CM
complex_matrix.real(CM) --> M
complex_matrix.sin(CM) --> CM
complex_matrix.sinh(CM) --> CM
complex_matrix.sqrt(CM) --> CM
complex_matrix.tan(CM) --> CM
complex_matrix.tanh(CM) --> CM

-- conversion
complex_matrix.to_complex_vector(CM) --> CV