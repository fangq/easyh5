function varargout = test_easyh5(testname, actual, expected, tol)
%
% test_easyh5(testname, actual, expected)
%   or
% test_easyh5(testname, actual, expected, tol)
% test_easyh5('reset')
% [total, failed, faillist] = test_easyh5('summary')
%
% run a single unit test and record whether it passed
%
% authors:Qianqian Fang (q.fang <at> neu.edu)
%
% input:
%      testname: a string describing the tested feature; the reserved names
%           'reset' and 'summary' are used to control the pass/fail tally
%      actual: the value produced by the tested function
%      expected: the value it should equal; compared with isequaln, so NaNs
%           on both sides count as equal
%      tol: (optional) absolute tolerance for numeric comparisons; when given
%           and non-zero, sizes must match and every element must agree within
%           tol. Use it for values that pass through a float conversion
%
% output:
%      when called as test_easyh5('summary'):
%      total: the number of tests run since the last 'reset'
%      failed: how many of those failed
%      faillist: a cell array with the names of the failed tests
%
% license:
%     GPLv3 or 3-clause BSD license, see https://github.com/NeuroJSON/easyh5
%
% -- this function is part of EasyH5 toolbox (https://github.com/NeuroJSON/easyh5)
%

persistent total failed faillist

if (isempty(total))
    total = 0;
    failed = 0;
    faillist = {};
end

if (nargin == 1 && ischar(testname))
    if (strcmp(testname, 'reset'))
        total = 0;
        failed = 0;
        faillist = {};
        return
    elseif (strcmp(testname, 'summary'))
        varargout = {total, failed, faillist};
        return
    end
end

if (nargin < 4)
    tol = 0;
end

total = total + 1;

if (tol > 0 && isnumeric(actual) && isnumeric(expected))
    ispass = isequal(size(actual), size(expected)) && ...
             all(abs(double(actual(:)) - double(expected(:))) <= tol);
elseif (exist('isequaln', 'builtin') || exist('isequaln', 'file'))
    ispass = isequaln(actual, expected);
else
    ispass = isequal(actual, expected);
end

if (ispass)
    fprintf(1, 'Testing %s: ok\n', testname);
else
    failed = failed + 1;
    faillist{end + 1} = testname;
    warning('Test %s: failed: expected %s, obtained %s', testname, ...
            describe(expected), describe(actual));
end

%% -------------------------------------------------------------------------
function str = describe(val)
%
% render a value compactly, so that a failure message stays readable even when
% the payload is a large array
%
if (ischar(val))
    str = ['''' val ''''];
elseif (isempty(val))
    str = sprintf('empty %s', class(val));
elseif (isnumeric(val) || islogical(val))
    if (numel(val) <= 8)
        str = sprintf('%s %s', class(val), mat2str(double(val), 6));
    else
        str = sprintf('%s %s array, first elements %s ...', class(val), ...
                      mat2str(size(val)), mat2str(double(val(1:4)), 6));
    end
else
    str = sprintf('%s %s', class(val), mat2str(size(val)));
end
