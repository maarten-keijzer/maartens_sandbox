
popsize = 10;
chromsize = 120;

nsteps = 100000;
mprob = 1/chromsize;

pop = rand(popsize,chromsize) > 0.5;
probs = ones(popsize, chromsize) * 1/chromsize;

self_adaptive = 1;
    
if self_adaptive
    threshold = 1.
else
    threshold = 0.9
end
accept = 0;

for i = 1:nsteps
    select = 1+floor(rand * popsize);

    
    indy = pop(select,:);
    prob = probs(select,:);
    
    newindy = indy;

    to_mutate = rand(size(prob)) < prob;

    newindy(to_mutate) = ~newindy(to_mutate);
    
    % crossover between probabilities

    other = 1+floor(rand * popsize);


    mask = rand(size(prob)) < threshold;
    newprobs = mask .* prob + ~mask .* probs(other,:);

    % and a bit of endogenous mutation on the probabilities
    if self_adaptive
	signs = rand(size(prob)) < 0.5;
	rands = rand(size(prob)) * 0.01; 
	newprobs = newprobs + signs .* rands - ~signs .* rands;
	newprobs = min(max(newprobs, 0.0001 * ones(size(newprobs))), 0.9999*ones(size(newprobs)));
    end
    
    fit_old = sum(indy);
    fit_new = sum(newindy);


    equal = (indy == newindy);

    p_forward = prod((1-prob).^equal) * prod( prob.^(~equal) );
    p_backward = prod((1-newprobs) .^ equal ) * prod(newprobs .^ (~equal) );
  
  
    p = fit_new / fit_old * p_backward / p_forward;
    
    if p >= 1 %rand < p
	accept = accept + 1;
	pop(select,:) = newindy;
	probs(select,:) = newprobs;
    end

    %pr = [pr;pop];
    
    if rem(i,100) == 0
	disp([accept/100,mean(mean(probs)), max(sum(pop'))])
	bar(mean(probs ));
	accept = 0;
    end

    
end


disp([accept/i,mean(probs'), max(sum(pop'))])
