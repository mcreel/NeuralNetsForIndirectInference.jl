%load simdata.paramspace;
load simdata.nojumps
simdata = clean_data(simdata);

% no dynamic jump intensity
% simdata = simdata(1:550000,[1:7 9:10 12:end]);

% all
%simdata = simdata(1:550000,[1:10 12:end]);

% no jumps
simdata = simdata(1:550000,[1:6 12:end]);
save -ascii simdata simdata;

