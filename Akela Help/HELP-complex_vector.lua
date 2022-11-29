-- construction
complex_vector() --> CV
complex_vector(N, C) --> CV
complex_vector(CV) --> CV
complex_vector(V1, V2) --> CV

complex_vector{C, C, ..., C} --> CV

complex_vector.polar(MOD, ARG) --> CV  
	w\ MOD and ARG are vectors of magnitude and angles

-- predicate
complex_vector.eqv(CV1, CV2) --> BOOL
complex_vector.find(CV, FUNC) --> I s.t. FUNC(V[I]) == true

-- io
print(CV) --> complex_vector(|CV|)

-- assignment
CV[i] = CN | N | {Re, Im}
CV[V] = CN | N | {Re, Im}
CV[{N, N, ..., N} = CN | N | {Re, Im}

-- selection
CN = CV[i]
CW = CV[V]
CV = CV{N, N, ..., N}
CV[FUNC] -> CV s.t. FUNC(CV[i]) == true
complex_vector.select(CU, V, [true]) - CU[i] s.t. V[i] == 1
complex_vector.select(CU, V, false) - CU[i] s.t. V[i] == 0

-- predicates
V1 == V2 --> BOOL
complex_vector.eqv(V1, V2) --> BOOL

-- size
#CV --> |CV|
complex_vector.size(CV) --> CV

-- arithmetic
CM <op> <exp> 
<exp> <op> CM

	w\ <op> is any valid arthimetic binary operator 
	w\ <expr> evaluates to any numerical value or aggregate

	Note that the above operations are performed element by element.

CV^N -> CV
-CV --> -CV[i]

-- structural functions
complex_vector.append(CV1, #) --> modiied CV1 .. #
complex_vector.append(CV1, C) --> modiied CV1 .. C
complex_vector.append(CV1, V) --> modiied CV1 .. V
complex_vector.append(CV1, CV) --> modiied CV1 .. CV

CV .. # --> new CV
CV .. C --> new CV
CV .. V --> new CV
CV .. CV --> new CV

complex_vector.reverse(V) --> CV[n], CV[n-1], CV[n-2], ...
complex_vector.shift(CV, nshift) --> CV s.t. CV[j] = CV[i] w\ j = i + nshift mod |CV|
complex_vector.slice(CV, [s = 1], [f = #CV]) --> CV[s], ..., CV[f]
	-- Note that negative slice parameters are referenced from end of vector.
complex_vector.exchange(CV, n) --> CV(real, imag) = CV(imag, real)

	
complex_vector.sort(CV) --> CV s.t. CV[1] < CV[2] < CV[3] ...
	NOTE: C1 < C2 iff if abs(C1) > abs(C2) else abs(C1) == abs(C2) then arg(C1) > arg(C2)

complex_vector.truncate(VV, n) --> CV[1], CV[2-1], ..., CV[n]
complex_vector.unique(V) --> W,I s.t. W[I] returns the original order of non duplicated elements in V


-- advanced functions
complex_vector.sum(CV) --> CV[1] + CV[2] + ...
complex_vector.prod(CV) --> CV[1] * CV[2] * ... * CV[#CV]

complex_vector.cumsum(CV) --> W s.t. W[i] = CV[1] + CV[2] + ... + CV[i]); i = [1..#CV]
complex_vector.cumprod(CV) --> W s.t. W[i] = CV[1], CV[2], ... CV[i]); i = [1..#CV]

-- no zero fill
complex_vector.fft(CV, [NFFT], [WINDOW = false], [REVERSE = true]) --> CV

-- zero fill	
complex_vector.fft(CV, NFFT, F0, F1, [WINDOW = false], [REVERSE = true]) --> CV

	NOTE: NFFT = 2^N s.t. NFFT >= #CV
	
-- statistical functions
complex_vector.avg(CV) --> C

--extended functions
complex_vector.dec(CV) --> 20 * log10(abs(V))
complex_vector.rotate(CV, angle) --> CV
complex_vector.rotate(CV, V) --> CV
complex_vector.unwrap(CV) --> V

-- standard library wrappers
complex_vector.abs(CV) --> V of sqrt(Re^2 + Im^2)
complex_vector.arg(CV) --> V of arctan2(Im, re)
complex_vector.conj(CV) --> CV of (Re, -Im)
complex_vector.cos(CV) --> CV
complex_vector.cosh(CV) --> CV
complex_vector.exp(CV) --> CV
complex_vector.imag(CV) --> V
complex_vector.log(CV) --> CV
complex_vector.log10(CV) --> CV
complex_vector.norm(CV) --> V of Re^2 + Im^2
complex_vector.pow(CV, n) --> CV
complex_vector.real(CV) --> V
complex_vector.sin(CV) --> CV
complex_vector.sinh(CV) --> CV
complex_vector.sqrt(CV) --> CV
complex_vector.tan(CV) --> CV
complex_vector.tanh(CV) --> CV

-- conversion
complex_vector.to_complex_matrix(CV, height, width) --> CM