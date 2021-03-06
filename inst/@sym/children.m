%% Copyright (C) 2014 Colin B. Macdonald
%%
%% This file is part of OctSymPy.
%%
%% OctSymPy is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published
%% by the Free Software Foundation; either version 3 of the License,
%% or (at your option) any later version.
%%
%% This software is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty
%% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
%% the GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public
%% License along with this software; see the file COPYING.
%% If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @documentencoding UTF-8
%% @deftypefn {Function File} {@var{r} =} children (@var{f})
%% Return "children" (terms, lhs/rhs, etc) of symbolic expression.
%%
%% For a scalar expression, return a row vector of sym expressions:
%% @example
%% @group
%% >> syms x y
%% >> f = 2*x*y + sin(x);
%% >> C = children(f)
%%    @result{} C = (sym) [2⋅x⋅y  sin(x)]  (1×2 matrix)
%%
%% >> children(C(1))
%%    @result{} ans = (sym) [2  x  y]  (1×3 matrix)
%% >> children(C(2))
%%    @result{} ans = (sym) x
%% @end group
%% @end example
%%
%%
%% For matrices/vectors, return a cell array where each entry is
%% a row vector.  The cell array is the same shape as the input.
%% @example
%% @group
%% >> A = [x*y 2; 3 x]
%%    @result{} A = (sym 2×2 matrix)
%%        ⎡x⋅y  2⎤
%%        ⎢      ⎥
%%        ⎣ 3   x⎦
%% >> children(A)
%%    @result{} ans =
%%      @{
%%      (sym) [x  y]  (1×2 matrix)
%%      (sym) 3
%%      (sym) 2
%%      (sym) x
%%      @}
%% >> size(children(A))
%%    @result{} ans =
%%         2   2
%% @end group
%% @end example
%%
%% A symbol/number/boolean has itself as children.
%%
%% @seealso{lhs, rhs}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function r = children(f)

  cmd = {
    'f, = _ins'
    'f = sympify(f)'  % mutable -> immutable
    'def scalarfcn(a):'
    '    if len(a.args) == 0:'
    '        return sympy.Matrix([a])'  % children(x) is [x]
    '    return sympy.Matrix([a.args])'
    'if f.is_Matrix:'
    '    r = [scalarfcn(a) for a in f.T]'  % note transpose
    'else:'
    '    r = scalarfcn(f)'
    'return r,' };

  r = python_cmd (cmd, f);

  if (~isscalar(f))
    r = reshape(r, size(f));
  end

end


%!test
%! % basics, sum
%! syms x y
%! f = 2*x + x*x + sin(y);
%! assert (isempty (setxor (children(f), [2*x x*x sin(y)])))

%!test
%! % basics, product
%! syms x y
%! f = 2*x*sin(y);
%! assert (isempty (setxor (children(f), [2 x sin(y)])))

%!test
%! % basics, product and powers
%! syms x y
%! f = 2*x^2*y^3;
%! assert (isempty (setxor (children(f), [2 x^2 y^3])))

%!test
%! % eqn, ineq
%! syms x y
%! lhs = 2*x^2; rhs = y^3 + 7;
%! assert (isequal (children(lhs == rhs), [lhs rhs]))
%! assert (isequal (children(lhs < rhs),  [lhs rhs]))
%! assert (isequal (children(lhs >= rhs), [lhs rhs]))

%!test
%! % matrix
%! syms x y
%! f = [4 + y  1 + x;  2 + x  3 + x];
%! c = children(f);
%! ec = {[4 y], [1 x]; [2 x], [3 x]};
%! assert (isequal (size(c), size(ec)))
%! for i=1:length(c)
%!   assert (isempty (setxor (c{i}, ec{i})))
%! end

%!test
%! % matrix, sum/prod
%! syms x y
%! f = [x + y; x*sin(y); sin(x)];
%! ec = {[x y]; [x sin(y)]; [x]};
%! c = children(f);
%! assert (isequal (size(c), size(ec)))
%! for i=1:length(c)
%!   assert (isempty (setxor (c{i}, ec{i})))
%! end

%!test
%! % scalar symbol
%! syms x
%! assert (isequal (children(x), x))

%!test
%! % scalar number
%! x = sym(6);
%! assert (isequal (children(x), x))
