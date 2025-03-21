function s = mergestruct(s1, s2)
%
% s=mergestruct(s1,s2)
%
% merge two struct objects into one
%
% authors:Qianqian Fang (q.fang <at> neu.edu)
% date: 2012/12/22
%
% input:
%      s1,s2: a struct object, s1 and s2 can not be arrays
%
% output:
%      s: the merged struct object. fields in s1 and s2 will be combined in s.
%
% license:
%     BSD or GPL version 3, see LICENSE_{BSD,GPLv3}.txt files for details
%
% -- this function is part of JSONLab toolbox (https://iso2mesh.sf.net/cgi-bin/index.cgi?jsonlab)
%

if (~isstruct(s1) || ~isstruct(s2))
    error('input parameters contain non-struct');
end
if (length(s1) > 1 || length(s2) > 1)
    error('can not merge struct arrays');
end
fn = fieldnames(s2);
s = s1;
for i = 1:length(fn)
    s.(fn{i}) = s2.(fn{i});
end
