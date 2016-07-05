function r = LocalConstant(y, weights, do_ci)
% x, x0: S by d
% y: S by 1
% h: scalar
r.S=length(y);

k = size(y,2);

test = weights > 0;
weights = weights(test,:);
y = y(test,:);

r.mean = (y'*(weights)/sum(weights))';
y = y.*(sqrt(weights)*ones(1,k));
x = sqrt(weights);

r.median = zeros(1,k);
for pardim = 1:k;
    y_sub = y(:,pardim);
    r.median(:,pardim) = rq(x, y_sub, 0.5); 
end;


if do_ci
        r.a = zeros(1,k); 
        r.b = zeros(1,k); 
        r.c = zeros(1,k); 
        r.d = zeros(1,k); 
        r.e = zeros(1,k); 
        r.f = zeros(1,k); 
        for pardim = 1:k;
            y_sub = y(:,pardim);
            %r.a(:,pardim)=rq(x, y_sub, 0.005); 
            %r.b(:,pardim)=rq(x, y_sub, 0.025); 
            r.c(:,pardim)=rq(x, y_sub, 0.05); 
            r.d(:,pardim)=rq(x, y_sub, 0.95); 
            %r.e(:,pardim)=rq(x, y_sub, 0.975); 
            %r.f(:,pardim)=rq(x, y_sub, 0.995); 
        end;
endif
