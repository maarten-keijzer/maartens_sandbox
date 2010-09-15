
dummy = 1;

function x = gauss(x)
    x = exp( - 0.5 * (x.*x) );
end

function prob = difference(x, y)
    prob = exp( 0.5 * (x.*x) - 0.5 * (y .* y) );
end

pop = randn(100000,1);
initial = pop;

for i=1:100000
    
    pop = sort(pop); 
    p = gauss(pop);
    pp = p / sum(p);

    disp([1./sqrt(2) - mean(gauss(pop)), mean(gauss(pop)), mean(accept) ]);
    
    newpop = pop + randn(size(pop)) * 0.5;

    prob = difference(pop, newpop);
    flip = rand(size(pop));
    
    accept = flip < prob;

    pop(accept) = newpop(accept);
    
    
end

