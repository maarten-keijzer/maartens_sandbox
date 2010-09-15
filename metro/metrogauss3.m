
dummy = 1;

function x = gauss(x)
    z = x - 5;
    y = x + 5;
    x = 2/3 * exp( -0.5 * sum(z.*z,2)) + 1/3*exp(-0.5 * sum(y.*y, 2));
end

function prob = difference(x, y)
    prob = gauss(y) ./ gauss(x);
end

d = 2;
pop = randn(100,d)*0.0001;
initial = pop;
eta = 1e-4^d;

acc=0;
tries=0;

for gen=1:1000000
    
    i = 1 + floor(rand * length(pop));
    j = i;
    while j==i; j = 1+floor(rand*length(pop)); end
    k = i;
    while k==i || k == j; k = 1+floor(rand*length(pop)); end;
    
    f = randn / randn; %1; %rand * rand;
    
    new = pop(i,:) + f * (pop(j,:) - pop(k,:)) + eta * randn;

    if rand < 1
	if rand < 0.5
	    i = j;
	else 
	    i = k;
	end
    end
    
    prob = difference(pop(i,:), new);
    
    tries+=1;
    if rand < prob
	pop(i,:) = new;
	acc+=1;
    end
   
    if rem(gen,100) == 0 
	more off;
	
	printf('gen %d, mean pop %f, acc rate %f\n', gen, mean(gauss(pop)), acc/tries);

	plot(pop(:,1), pop(:,2),'*');
	
    end
   
end

