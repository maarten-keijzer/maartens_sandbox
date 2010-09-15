
dummy = 1;

function x = gauss(x)
    x = exp( - 0.5 * (x.*x) );
end

function prob = difference(x, y)
    prob = exp( 0.5 * (x.*x) - 0.5 * (y .* y) );
end

pop = randn(500,1);
initial = pop;

tr = [];

acc=0;
tries=0;

for gen=1:1000000
    
    i = 1 + floor(rand * length(pop));
    j = i;
    while j==i; j = 1+floor(rand*length(pop)); end
    k = i;
    while k==i || k == j; k = 1+floor(rand*length(pop)); end;
    
    f = 0.1;%randn/randn; %1; %rand * rand;
    
    if rand < 0.9
	f = 1/f;
    end
    
    eta = 1e-6;
    
    new = pop(i) + f * (pop(j) - pop(k));
    
    r = i;
    if rand < 0.5
	if rand < 0.5
	    r = j;
	else 
	    r = k;
	end
    end
    
    prob = difference(pop(r), new);
    
    tries+=1;
    if rand < prob
	pop(r) = new;
	acc+=1;
    end
    
    tr(length(tr)+1) = pop(r);
   
    if rem(gen,1000) == 0 
	more off;
	printf('gen %d, mean pop %f, mean trace %f, acc rate %f\n', gen, mean(gauss(pop)), mean(gauss(tr)) - 1/sqrt(2), acc/tries);
    end
   
end

