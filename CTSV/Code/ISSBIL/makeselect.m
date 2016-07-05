a = [1:56]';
a = [rand(56,1) a];
a = sortbyc(a,1);
a = a(1:17,2);
a = a';
save selected.random a;
