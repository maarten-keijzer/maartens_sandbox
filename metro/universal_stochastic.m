function idx = universal_stochastic(w)
% Will return length(w) randomly sampled indices to the elements of w
% proportional to w with zero bias and minimal spread
    
    w = cumsum(w);
    w = w / w(end); % sum to one
    
    n = length(w);
    idx = zeros(n,1);
    fortune = rand * 1/n; %startpoint
    for i = 1:n
	indices = find(fortune < w);
	idx(i) = indices(1); % pick the bin this number falls in
	
	fortune = fortune + 1/n; % add fixed stepsize
    end
    
    
	
    

