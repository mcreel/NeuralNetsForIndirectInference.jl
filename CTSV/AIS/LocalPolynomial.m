function r = LocalPolynomial(y, x, x0, weights, do_ci, order=1)
% x, x0: S by d
% y: S by 1
% h: scalar
test = weights > 0;
% if no positive weight, use equal weighting
if sum(test) == 0
        "LocalPolynomial: no positive weights";
        test = ones(size(test));
        weights = test/size(test,1);
endif        
weights = weights(test,:);
y = y(test,:);
x = x(test,:);
r.S=length(y);
k = size(y,2);
diff = x - x0;
if order == 2
        diff = [diff 0.1*diff.^2];
endif        
d = size(diff,2);

diff1 = [ones(size(diff,1),1) diff];
y = y.*(sqrt(weights)*ones(1,k));
x = diff1.*(sqrt(weights)*ones(1, d+1));
r.mean = ols(y, x);
r.mean = r.mean(1,:);
r.median = zeros(d+1,k);
for pardim = 1:k;
    y_sub = y(:,pardim);
    r.median(:,pardim) = rq(x, y_sub, 0.5); 
end;
r.median = r.median(1,:);

if do_ci
        r.a = zeros(d+1,k); 
        r.b = zeros(d+1,k); 
        r.c = zeros(d+1,k); 
        r.d = zeros(d+1,k); 
        r.e = zeros(d+1,k); 
        r.f = zeros(d+1,k); 
        for pardim = 1:k;
            y_sub = y(:,pardim);
            %r.a(:,pardim)=rq(x, y_sub, 0.005); 
            %r.b(:,pardim)=rq(x, y_sub, 0.025); 
            r.c(:,pardim)=rq(x, y_sub, 0.05); 
            r.d(:,pardim)=rq(x, y_sub, 0.95); 
            %r.e(:,pardim)=rq(x, y_sub, 0.975); 
            %r.f(:,pardim)=rq(x, y_sub, 0.995); 
        end;
        r.a = r.a(1,:);
        r.b = r.b(1,:);
        r.c = r.c(1,:);
        r.d = r.d(1,:);
        r.e = r.e(1,:);
        r.f = r.f(1,:);
endif
