
xplot = [-5:0.01:15]'; yplot=func(xplot);

plot(xplot,yplot);

popsize=30;
pop = randn(popsize,1);

chains = [-1,-1];        % default chains
hst    = [10 , -10; 0, 0.00001]; % dummy steps
accept = [0,1];
fit    = func(hst);

for gen=1:100000
    
    chain = floor(1 + rand * popsize);

    idx = find(chains != chain);

    hist_to_use = hst(idx,:);
    accept_to_use = accept(idx);

    accept_idx = find(accept_to_use == 1);
    failed_idx  = find(accept_to_use == 0);

    dist = (hist_to_use(:,1) - hist_to_use(:,2)).^2;
    
    std_overall = sqrt( mean(dist) );
    std_accept = sqrt( mean(dist(accept_idx)));
    std_failed = sqrt( mean(dist(failed_idx)));
    
    accept_prob = mean( accept(idx) );
    
    if accept_prob < 0.5
	rate_to_use = std_accept;
    else
	rate_to_use = std_failed;
    end
    
    new = pop(chain) + randn * rate_to_use;

    mu = mean(hist_to_use(:,1));
    sigma = std(hist_to_use(:,1));
    
    if accept_prob < 0.5 % decrease sigma
	sigma /= 1.1;
    else
	sigma *= 1.1;
    end
    
    new = pop(chain) + randn*sigma;
    
    chains = [chains, chain];
    hst    = [hst; pop(chain), new];
    fit    = [fit; func(new),func(pop(chain))]; 
    
    %fact = exp( -0.5*(pop(chain)-mu).^2/(sigma.*sigma) + 0.5*(new-mu).^2/(sigma*sigma) );
    fact=1;
    
    if rand < func(new)/func(pop(chain)) * fact 
	pop(chain) = new;
	accept = [accept,1];	
    else
	accept = [accept,0];
    end
    
    if mod(gen,100)==1
	disp( [sigma, mean(accept), std_overall, std_accept, std_failed] );
	hold off;
	plot(xplot,yplot);
	hold on;
	[u,v] = hist(hst(:,1),50);
	bar(v,u/max(u)*max(yplot));
	hold off;
    end

    if length(accept) > 4000
	disp('forgetting');
	accept = accept(2000:end);
	hst = hst(2000:end,:);
	chains = chains(2000:end);
	fit = fit(2000:end,:);
    end

end

