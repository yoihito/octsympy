function extract_tests_for_matlab()

  dirs = {'.', '@sym', '@symfun'};
  dirstr = {'', 'sym', 'symfun'};

  outdir = 'tests_matlab';

  for j=1:length(dirs)
    files = dir(dirs{j});

    for i=1:length(files)
      mfile = files(i).name;
      if ( (~files(i).isdir) && strcmp(mfile(end-1:end), '.m') )
        %str = mfile(1:end-2);
        fprintf('>>> Looking for tests in: %s', mfile);
        tf = proc_file(dirs{j}, dirstr{j}, mfile, outdir);
        if tf
          fprintf('\t[done]\n');
        else
          fprintf('\t[no tests]\n');
        end
      end
    end
  end
endfunction



function r = proc_file(base, basestr, nm, outdir)

  %nm = 'symfun.m';
  %base = '@symfun';

  name_no_m = nm(1:end-2);
  in_name = [base '/' nm];
  body = __extract_test_code(in_name);

  r = true;
  if isempty(body)
    r = false;
    return
  end

  %% process it a bit
  % Chop it up into blocks for evaluation.
  %__lineidx = find (__body == "\n");
  %__blockidx = __lineidx(find (! isspace (__body(__lineidx+1))))+1;

  nl = sprintf('\n');

  % add an extra newline to ensure final line has one
  body = [body nl];

  body = regexprep(body, '^test\n', ['%test' nl], 'lineanchors');
  body = regexprep(body, '^test ', ['%test' nl], 'lineanchors');
  body = regexprep(body, '^(shared .*)\n', ['%$1' nl], 'lineanchors', 'dotexceptnewline');
  body = regexprep(body, '^xtest\n( [^\n]*\n)*', ['%xtest' ...
                      ' (**TEST EXPECTED TO FAIL: REMOVE**)' nl], 'lineanchors');
  body = regexprep(body, '^error [^\n]+\n( [^\n]*\n)*', ['%error' ...
                      ' (**ERROR TEST: NOT SUPPORTED, REMOVED**)' nl], 'lineanchors');

  % output it
  out_name = ['tests_' basestr '_' name_no_m];
  full_out_name = [outdir '/' out_name '.m'];
  fid = fopen (full_out_name, 'w');
  fprintf(fid, 'function %s()\n', out_name);
  fprintf(fid, '%%%% Auto extracted tests from %s\n', in_name);
  fprintf(fid, '%% This file autogenerated from the inline Octave tests\n');
  fprintf(fid, '%% in the above file.  Don''t modify directly.\n');
  % FIXME: fprintf better than this schar thing?  its for utf8
  fwrite(fid, body, "schar");
  fprintf(fid, '\n\n\n%%%% End of tests\n');
  fprintf(fid, 'disp(''    Passed tests for %s'')\n', in_name);
  fclose(fid);
endfunction



% This code from Octave source: /scripts/testfun/test.m
% Copyright (C) 2005-2013 Paul Kienzle
% GPL
function body = __extract_test_code (nm)
  fid = fopen (nm, "rt");
  body = [];
  if (fid >= 0)
    while (! feof (fid))
      ln = fgetl (fid);
      if (length (ln) >= 2 && strcmp (ln(1:2), "%!"))
        body = [body, "\n"];
        if (length (ln) > 2)
          body = [body, ln(3:end)];
        endif
      endif
    endwhile
    fclose (fid);
  endif
endfunction
