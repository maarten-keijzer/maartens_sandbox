
dummy = 1;

function x = gauss(x)
    z = x - 19;
    y = x + 30;
    x = exp( - 0.5 * (x.*x) ) + exp( -0.5 * (z.*z)) + 2*exp(-0.5 * (y.*y));
end

function prob = difference(x, y)
    prob = gauss(y) ./ gauss(x);
end

pop = randn(500,1);
initial = pop;

acc=0;
tries=0;

for gen=1:1000000
    
    i = 1 + floor(rand * length(pop));
    j = i;
    while j==i; j = 1+floor(rand*length(pop)); end
    k = i;
    while k==i || k == j; k = 1+floor(rand*length(pop)); end;
    
    f = rand / rand; %1; %rand * rand;
    if rand < 0
	disp('huh');
	f = 1/f;
    end
    
    eta = 1e-6;
    
    new = pop(i) + f * (pop(j) - pop(k)) + eta * randn;

    factor = 1;
    if rand < 0.01
	%factor = 2; 
	if rand < 0.5
	    i = j;
	else 
	    i = k;
	end
    end
    
    prob = difference(pop(i), new) * factor;
    
    tries+=1;
    if rand < prob
	pop(i) = new;
	acc+=1;
    end
   
    if rem(gen,1000) == 0 
	more off;
	printf('gen %d, mean pop %f, acc rate %f\n', gen, mean(gauss(pop)), acc/tries);
	hist(pop,150);
    end
   
end

