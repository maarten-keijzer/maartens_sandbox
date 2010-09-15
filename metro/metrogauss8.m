
dummy = 1;

function x = gauss(x)
    z = x -5;
    %y = x + 1;
    %x = exp( - 0.5 * (x.*x) ) + exp( -0.5 * (z.*z)) + 2*exp(-0.5 * (y.*y));
    x = exp( -0.5 * (x.*x) ) + exp(-0.5 * (z.*z));
    % x = exp( -0.5 * (z.*z) );
end


function p = mutprob(x, y, s)
     
     p = 1 / sqrt(2 * pi * s * s) * exp( -1/2 * (x - y)^2 / (s*s));

end


acc=0;
tries=0;
temp = 1;

popsize = 200;
chromsize = 1;
pop = randn(popsize, chromsize);
mutrate = 0.1;

all = [];

for gen=1:10000000
    
    i = 1 + floor(popsize * rand);
    j = i;
    while j==i 
        j = 1 + floor(popsize * rand);
    end

    nwi = pop(j,:) + randn(1, chromsize) * mutrate;
    nwj = pop(i,:) + randn(1, chromsize) * mutrate;

    fi = gauss(pop(i,:));
    fj = gauss(pop(j,:));
    fii = gauss(nwi);
    fjj = gauss(nwj);

    tries += 2;

    if rand < fii ./ fi 
        acc += 1;
        pop(i,:) = nwi;
    end

    if rand < fjj / fj 
        acc += 1;
        pop(j,:) = nwj;
    end

    all = [all;pop(i,:)];

    if rem(gen,5000) == 0 
        %all =pop;
         
        more off;
	printf('gen %d, mean %f, std %f, acc rate %f n = %d\n', gen, mean(all), std(all), acc/tries, size(pop,1));
	%hist(pop,150);

	hist(all,150);
        %hold on
        %plot(pop, zeros(size(pop)), 'b*');
        %hold off
        if length(all) > 50000
            all = all(1:2:end);
        end
    end
   
end

