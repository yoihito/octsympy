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
%% @deftypefn {Function File} {@var{r} =} octsympy_config ()
%% Configure the octsympy system.
%%
%% Python executable path/command:
%% @example
%% octsympy_config python '/usr/bin/python'
%% octsympy_config python 'C:\Python\python.exe'
%% octsympy_config python 'N:\myprogs\py.exe'
%% @end example
%% Default is an empty string; in which case octsympy just runs
%% @code{python} and assumes the path is set appropriately.
%% FIXME: need to make sure default works on Windows too.
%%
%% Display of syms:
%% @example
%% octsympy_config display flat
%% octsympy_config display ascii
%% octsympy_config display unicode
%% @end example
%% By default OctSymPy uses a unicode pretty printer to display
%% symbolic expressions.  If that doesn't work (e.g., if you
%% see @code{?} characters) then try the @code{ascii} option.
%%
%% Communication mechanism:
%% @example
%% octsympy_config ipc default    % default, autodetected
%% octsympy_config ipc system     % slower
%% octsympy_config ipc systmpfile % debugging!
%% octsympy_config ipc sysoneline % debugging!
%% w = octsympy_config('ipc')     % query the ipc mechanism
%% @end example
%% The default will typically be the @code{popen2} mechanism which
%% uses a pipe to communicate with Python and should be fairly fast.
%% There are other options which are mostly based on calls using the
%% @code{'system()'} command.  These are slower as a new Python
%% process is started for each operation (and many commands use more
%% than one operation).
%% Other options for @code{octsympy_config ipc} include:
%% @itemize
%% @item popen2, force popen2 choice (e.g., on Matlab were it would
%% not be the default).
%% @item system, construct a large multi-line string of the command
%% and pass directly to the python interpreter with the
%% @code{system()} command.  Warning: currently broken on Windows.
%% @item systmpfile, output the python commands to a @code{temp_sym_python_cmd.py} file and then call that [for debugging, may not be supported long-term].
%% @item sysoneline, put the python commands all on one line and pass to "python -c" using a call to @code{system()}.  [for debugging, may not be supported long-term].
%% @end itemize
%%
%% Snippets: when displaying a sym object, we show the first
%% few characters of the SymPy representation.
%% @example
%% octsympy_config snippet 1|0   % or true/false, on/off
%% @end example
%%
%% Report the version number:
%% @example
%% octsympy_config version
%% @end example
%%
%% @seealso{sym, syms, octsympy_reset}
%% @end deftypefn

function varargout = octsympy_config(cmd, arg)

  persistent settings

  if (isempty(settings))
    settings = 42;
    octsympy_config('defaults')
  end

  if (nargin == 0)
    varargout{1} = settings;
    return
  end


  switch lower(cmd)
    case 'defaults'
      settings = [];
      settings.ipc = 'default';
      settings.display = 'unicode';
      settings.snippet = true;
      settings.whichpython = '';

    case 'version'
      assert (nargin == 1)
      varargout{1} = '0.0.4-git';

    case 'display'
      if (nargin == 1)
        varargout{1} = settings.display;
      else
        arg = lower(arg);
        assert(strcmp(arg, 'flat') || strcmp(arg, 'ascii') || ...
               strcmp(arg, 'unicode'))
        settings.display = arg;
      end

    case 'snippet'
      if (nargin == 1)
        varargout{1} = settings.snippet;
      else
        settings.snippet = tf_from_input(arg);
      end

    case 'python'
      if (nargin == 1)
        varargout{1} = settings.whichpython;
      elseif (isempty(arg) || strcmp(arg,'[]'))
        settings.whichpython = '';
        octsympy_reset()
      else
        settings.whichpython = arg;
        octsympy_reset()
      end

    case 'ipc'
      if (nargin == 1)
        varargout{1} = settings.ipc;
      else
        octsympy_reset()
        settings.ipc = arg;
        switch arg
          case 'default'
            disp('Choosing the default [autodetect] octsympy communication mechanism')
          case 'system'
            disp('Forcing the system() octsympy communication mechanism')
          case 'popen2'
            disp('Forcing the popen2() octsympy communication mechanism')
          otherwise
          warning(['Unknown/unsupported IPC mechanism: hope you know what you''re doing'])
        end
      end

    otherwise
      error ('invalid input')
  end
end


function r = tf_from_input(s)

  if (~ischar(s))
    r = logical(s);
  elseif (strcmpi(s, 'true'))
    r = true;
  elseif (strcmpi(s, 'false'))
    r = false;
  elseif (strcmpi(s, 'on'))
    r = true;
  elseif (strcmpi(s, 'off'))
    r = false;
  elseif (strcmpi(s, '[]'))
    r = false;
  else
    r = str2double(s);
    assert(~isnan(r), 'invalid expression to convert to bool')
    r = logical(r);
  end
end


%!test
%! octsympy_config('defaults')
%! assert(strcmp(octsympy_config('ipc'), 'default'))
