complex() --> (0, 0)
complex(Re) --> (Re, 0)
complex(Re, Im) --> (Re, Im)
complex({Re, Im}) --> (Re, Im)
complex(C) --> C

C[1] = Re
C[2] = Im
Re = C[1]
Im = C[2]
#C --> 2

-- arithmetic
C <op> <exp> 
<exp> <op> C

	w\ <op> is any valid arthimetic binary operator 
	w\ <expr> evaluates to any numerical value or aggregate

	Note that the above operations are performed element by element.

-C - (-Re, -Im)

print(C) --> complex.(Re, Im)

complex.abs(C) --> sqrt(Re^2+ Im^2)
complex.arg(C) --> arctan2(Im, Re)
complex.conj(C) --> (Re, -Im)
complex.cos(C) --> C
complex.cosh(C) --> C
complex.dec(C) --> 20*log10(abs(C))
complex.eqv(C1, C2) --> BOOL
complex.exp(C) --> C
complex.imag(C) --> Im
complex.log(C) --> C
complex.log10(C) --> C
complex.norm(C) --> Re^2 + Im^2
complex.polar(mod, arg) --> C
complex.pow(C) --> C
complex.real(C) --> Re
complex.rotate(C, theta) --> C
complex.sin(C) --> C
complex.sinh(C) --> C
complex.sqrt(C) --> C
complex.tan(C) --> C
complex.tanh(C) --> C
