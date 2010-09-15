more off;
[x,y] = meshgrid([-1:0.05:1],[-1:0.05:1]);
target = x.^2 + y.^2 + sin(x); % circle


x = [-2:0.05:2];
target = 0.3 * x .* sin( 2* pi * x); % + randn(size(x)) * 0.1;

xorg = x;

%target(15:20) += randn(1,6) * 0.3;
%target = x.*x + randn(size(x)) * 0.1;
%target(5) = 1;

%x = [0:0.1:10];
%target = x + randn(size(x))*0.1;
%target(18:22) = 10;
%target /= 10;

dorg = [x(:), ones(size(x(:)))];
torg = target(:);

d=dorg;
t=torg;

% take some stuff out of the middle
if 0
    leave_out = 30:50;
    d(leave_out,:) = [];
    t(leave_out) = [];
    x(leave_out) = [];
end

nhidden = 10;

function s = sigmoid(x)
    s = 1 ./ (1 + exp(-x));
end

function [out, hid] = evaluate(data, network) 
    
    hid = sigmoid( data * network.hidden );
    hid = [hid, ones(size(hid,1),1)];
    
    out = hid * network.out ;
end

function ll = loglik(output, target, stdevs) 
    stdevs = exp(stdevs);
    ll = -sum( (output - target).^2 ./ (2 * stdevs .^ 2) );
end

function acc = accuracy(output, target)
    acc = -loglik(output,target, zeros(size(target)) ) / length(target); 
end

function ll = loglik_std_org(predictions, target, stdevs)
    stdevs = exp(stdevs)
    p = mean(predictions);
    
    t = ones(size(predictions,1), 1) * p;
     
    ll = -sum( log( sqrt(2*pi*stdevs.^2))) - sum( mean( (predictions - t).^2 ) ./ (2 * stdevs' .^2 ) );
    
end

function ll = loglik_std(predictions, target, stdevs, idx)
    
    stdevs = exp(stdevs);
    s = stdevs(idx); 
    p = mean(predictions(:,idx)); %predictions(:, idx)
    n = size(predictions, 1);
    
    bias = - n * sum( ( p - target(idx) ).^ 2 ./ (2 * s .^ 2) );
    variance = -sum( ( predictions(:, idx) - p).^2 ./ (2 * s .^2) );
    
    total = -sum( (predictions(:,idx) - target(idx)) .^ 2 ./ (2 * s .^ 2));
    
    ll = -n * log( sqrt(2*pi*s.^2)) + variance; 
end

function net = half(net1, net2) 
    
    f = 2 * rand;
    eta = 1e-4;

    hid = net1.hidden + f * (net1.hidden - net2.hidden);
    out = net1.out + f * (net1.out - net2.out);
    hid += randn(size(hid)) * eta;
    out += randn(size(out)) * eta;
   
    net.hidden = hid;
    net.out = out;
   
end


function n = differ(net1, net2, net3) 
    
    n = half(net1, net2);
    return;
    
    %fact = (randn) / (randn);
    fact = 1;
    
    eta = 1e-6;
    
    global normal_metro;
    if normal_metro == 1
	fact = 0;
	eta = 0.001;
    end
    
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

global normal_metro;
normal_metro = 0;
popsize = 150;
neigh = min(150, popsize);

networks = [];
fit = [];

predictions = zeros(popsize , length(t));
stdevs = zeros(size(t));

for i = 1:popsize
    hid = randn( size(d,2), nhidden);
    out = randn( nhidden+1, 1);


    networks(i).hidden = hid;
    networks(i).out = out;
    
    if i < 0 && normal_metro == 0
	networks(i) = differ(networks(1), networks(2), networks(3));
    end
    
    % quick optimization, lr on output
    %[l,h] = evaluate(d, networks(i));
    %networks(i).out = h \ t;
   
   
    l = evaluate(d, networks(i));
    
    predictions(i,:) = l';
    fit(i) = loglik(l, t, stdevs);
end

best = 1e+20;

for gen = 1:1000000
    
    acc = 0;
    tries = 0;
    
    for ii = 1:popsize
		
	q = 1 + floor(rand * popsize);
	
	i = 1 + rem(popsize + q - 1 + floor(rand * (2*neigh + 1)) - neigh , popsize );
	
	j = i;
	while j == i
	    j = 1 + rem(popsize + q - 1 + floor(rand * (2*neigh + 1)) - neigh , popsize );
	end
	
	k = i;
	while k == i || k == j
	    k = 1 + rem(popsize + q - 1 + floor(rand * (2*neigh + 1)) - neigh , popsize );
	end
	
	new = differ(networks(i), networks(j), networks(k));
   
	l = evaluate(d, new);
	f = loglik(l,t, stdevs);

	if normal_metro == 0 && rand < 0.5
	    if rand < 1/2
		i = j;
	    else
		i = k;
	    end
	end
	
	fit(i) = loglik( evaluate(d, networks(i)), t, stdevs);
	
	prob = exp( f - fit(i) );
	
	tries += 1;
	if rand < prob
	    predictions(i,:) = l';
	    acc += 1;
	    ll = l;
	    err = accuracy(l,t);
	    if err < best
		best = err
	    end
	    %disp([fit(i), f, accuracy(l,t)])
	    fit(i) = f;
	    networks(i) = new;
	end
	
	
    end
    
    printf('gen %d, #evals %d, accept rate %f\n',gen, (1+gen)*popsize, acc/tries);
    
    if 0 
    for i=1:popsize
	idx = 1 + floor(rand * length(stdevs) );
	
	newstd = stdevs;
	newstd(idx) = stdevs(idx) + randn * 1;
	newstd = ones(size(stdevs)) * newstd(idx);

	ll_org = loglik_std(predictions, target, stdevs, idx);
	ll_new = loglik_std(predictions, target, newstd, idx);
	
	prob = exp(( ll_new - ll_org) );
	if rand < prob
	    stdevs = newstd;
	    %printf('std = %f %f\n', mean(stdevs), std(stdevs) );
	end
    end
    else
	stdevs = log( ones(size(stdevs)) * 0.1);
    end

   if rem(gen,40) == 1 
	n = min(length(networks), 50);

	pred = zeros( n, length(torg) );
	for i=1:size(pred,1)
	    if n < length(networks)
		idx = 1 + floor(rand * length(networks));
	    else
		idx = i;
	    end
	    
	    pred(i,:) = evaluate(dorg, networks(idx))';
	end
	plot(xorg,pred,'r',xorg,torg,'g');
	%plot(x,target);
	hold on;
	errorbar(x, mean(predictions), exp(stdevs) );
	hold off;
    end
end


