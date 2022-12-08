-- construction
vector() --> V

vector(N) --> V
vector(N, N0) --> V
vector(N, N0, dN) --> V
vector(V) --> W s.t. W is a copy of V

vector{N, N, ..., N} --> V

-- io
print(V) --> vector(|V|)

-- assignment
V[N] = N
V[V] = N
V[{N, N, ..., N] = N

-- selection
N = V[i]
V = V[V]
V = V[{N, N, ..., N}]
V = V[FUNCTION] -> V s.t. FUNC(V[i]) == true
vector.select(U, V, [true]) - U[i] s.t. V[i] == 1
vector.select(U, V, false) - U[i] s.t. V[i] == 0

-- extents
#V --> |V|
vector.size(V) --> #V

-- arithmetic
V <op> <exp> 
<exp> <op> V

	w\ <op> is any valid arthimetic binary operator 
	w\ <expr> evaluates to any numerical value or aggregate

	Note that the above operations are performed element by element.

V^N --> V
-V --> V

-- predicate functions
vector.bool(V, REL, N) --> W s.t. V[w[i]] REL N == true

    where REL = EQ | LT | LE | GT | GE

vector.eqv(V, W) --> #V == #W && V[i] == W[i]; i = [1..#V]
vector.find(V, FUNC) --> I s.t. FUNC(V[I]) == true

-- structural functions
vector.append(V, N) --> modified V .. N
vector.append(V1, V2) --> modified V1 .. V2

V .. # --> new V
V .. V --> new V

vector.shift(V, nshift) --> V s.t. V[j] = V[i] w\ j = i + nshift mod |V|

vector.slice(V, [s = 1], [f = #V]) --> V[s], ..., V[f]
  -- Note that negative slice parameters are referenced from end of vector.
	
vector.reverse(V) --> V[n], V[n-1], V[n-2], ...

vector.sort(V) --> V s.t. V[1] < V[2] < V[3] ...
vector.sort_indexed(V) --> I s.t. V[I[1]] < V[I[2]] < V[I[3]] ...

vector.truncate(V, n) --> V[1], V[2-1], ..., V[n]
vector.unique(V) --> W,I s.t. W are the unique values and 
                              I points to their location in V

-- advanced functions
vector.cumsum(V) --> W s.t. W[i] = V[1] + V[2] + ... + V[i]); i = [1..#V]
vector.cumprod(V) --> W s.t. W[i] = V[1], V[2], ... V[i]); i = [1..#V]

vector.diff(V) --> W s.t. W[i] = V(i) - V[i  - 1];  i = [2..#V]

vector.norm(V, [peak = 1.0]) --> V s.t. max(V) == peak

vector.prod(V) --> V[1] * V[2] * ... * V[#V]
vector.sum(V) --> V[1] + V[2] + ... + V[#V]
vector.unwrap(V) --> V

vector.linear_regress(V) --> m, b


-- statistical functions
vector.avg(V) --> average value
vector.min(V) --> V[i],i s.t. V[i] == minimum_value
vector.max(V) --> V[i],i s.t. V[i] == maximum_value
vector.hist(V, [nbin = 256]) --> X, Y s.t. |X| & |Y| == nbin
vector.std(V) --> standard deviation
vector.stats(V) --> MIN, MAX, AVG, STD

-- standard library wrappers
vector.abs(V) --> V
vector.acos(V) --> V
vector.asin(V) --> V
vector.atan(V) --> V
vector.atan2(V, V) --> V
vector.cosh(V) --> V
vector.exp(V) --> V
vector.log(V) --> V
vector.log10(V) --> V
vector.pow(V) --> V
vector.sin(V) --> V
vector.sinh(V) --> V
vector.sqrt(V) --> V
vector.tan(V) --> V
vector.tanh(V) --> V

-- extensions
vector.floor(V) --> V
vector.ceil(V) --> V

-- filters
vector.parzen(N) --> V
vector.hanning(N) --> V
vector.hamming(N) --> V
vector.blackman(N) --> V
vector.welch(N) --> V

-- conversion
vector.to_matrix(V, height, width) --> M