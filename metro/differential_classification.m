
[x,y] = meshgrid([-1:0.05:1],[-1:0.05:1]);
target = x.^2 + y.^2 < 0.5; % circle

%target = sigmoid(x+y) > 0.5;

d = [x(:), y(:), ones(size(x(:)))];
t = target(:);

nhidden = 10;

function s = sigmoid(x)
    s = 1 ./ (1 + exp(-x));
end

function out = evaluate(data, network) 
    
    hid = sigmoid( data * network.hidden );
    hid = [hid, ones(size(hid,1),1)];
    out = sigmoid( hid * network.out );
    
end

function ll = loglik(output, target) 
    ll = sum( log(output) .* target + log(1-output) .* (1-target) );
end

function acc = accuracy(output, target)
    acc = sum( (output > 0.5) == target);
end

function n = differ(net1, net2, net3) 
    fact = 0.5;
    eta = 0.05;
    hid = net1.hidden + fact * (net2.hidden - net3.hidden);
    %hid = net1.hidden;
    hid += randn(size(hid)) * eta;
    
    out = net1.out + fact * (net2.out - net3.out);
    %out = net1.out;
    out += randn(size(out)) * eta;

    n = [];
    n.hidden = hid;
    n.out = out;
    
end

popsize = 50;
networks = [];
fit = [];

for i = 1:popsize
    hid = randn( size(d,2), nhidden);
    out = randn( nhidden+1, 1);

    networks(i).hidden = hid;
    networks(i).out = out;
    
    l = evaluate(d, networks(i));
    fit(i) = loglik(l, t);
end

best = -1e+20;

for gen = 1:1000000
    
    acc = 0;
    tries = 0;
    
    for i = 1:popsize
	
	j = i;
	while j == i
	    j = 1 + floor(rand * popsize);
	end
	
	k = i;
	while k == i || k == j
	    k = 1 + floor(rand * popsize);
	end
	
	new = differ(networks(i), networks(j), networks(k));
   
	l = evaluate(d, new);
	f = loglik(l,t);

	prob = exp( f - fit(i) );
	
	tries += 1;
	if rand < prob
	    acc += 1;
	    ll = l;
	    if f > best
		best = f
		mesh(x,y, reshape(ll, size(x)));
	    end
	    disp([fit(i), f, accuracy(l,t)])
	    fit(i) = f;
	    networks(i) = new;
	end
    end
    
    printf('gen %d, accept rate %f\n',gen, acc/tries);
    
end


