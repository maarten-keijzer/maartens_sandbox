
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
    
    if rand < 0.5
	j = i;
	while j==i; j = 1+floor(rand*length(pop)); end
   
	if rand < 0.5
	    f = 0.5;
	else
	    f = -1;
	end
	
	new = pop(i) + f * (pop(j) - pop(i));
	%new = pop(i) + randn;
	
	r = i; 
    else
	new = pop(i) + randn;
	r = i;
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

