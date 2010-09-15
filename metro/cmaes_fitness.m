1;
global best;
best = 1e+20;

global x;
global target;

x = [-2:0.05:2];
target = 0.3 * x .* sin( 2* pi * x) + randn(size(x)) * 0.1;

function fit = calculate_fitness(net)
    nhidden = 10;
    
    global x;
    global target;
    
    d = [x(:), ones(size(x(:)))];
    t = target(:);
    
    if nargin < 1 % output default network
	hid = zeros( size(d,2), nhidden);
	out = zeros( nhidden+1, 1);

	fit = hid(:);
	fit = [fit;out(:)];
	return
    end
  
    % extract network
    n = size(d,2);
    m = nhidden;

    hid = net(1 : n*m);
    out = net(n*m+1 : end);

    hid = reshape(hid, n, m);

    net.hidden = hid;
    net.out = out;
  
    l = evaluate(d, net);
    fit = sse(l, t);
    
    global best;

    if fit < best
	best = fit;
	plot(x,l,'r',x,t,'g*');
    end

    
end

function s = sigmoid(x)
    s = 1 ./ (1 + exp(-x));
end

function [out, hid] = evaluate(data, network) 
    
    hid = sigmoid( data * network.hidden );
    hid = [hid, ones(size(hid,1),1)];
    
    out = hid * network.out ;
end

function ll = sse(output, target) 
    ll = 0.5 * sum( (output - target).^2 );
end


