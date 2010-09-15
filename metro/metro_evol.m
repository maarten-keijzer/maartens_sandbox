more off;

function fit = fitness(x)
    fit = exp(- 0.5 * sumsq(x)) + 2 * exp(- 0.5 * sumsq(x - 5) );
end

function p = prob(mu, d, x)
    
    s = sumsq(mu - x);

    p = 1 / (d * sqrt(2*pi)) * exp( - 0.5 * s / (d*d));
end;

function p = lprob(mu, d, x)
    
    s = sumsq(mu - x);

    p =  - 0.5 * s / (d*d);
end;

function [mu, d] = findNN(pop, elem, k)
   
   %mu = mean(pop')';
   %d = std(pop(:));
   %return
    
   el = repmat(elem, 1, size(pop,2));
    
   diff = sumsq(el - pop);
   
   [dummy, idx] = sort(diff);

   selection = pop(:, idx(1:k));
    
    mu = mean(selection')';
    d = mean(std(selection' ));
    
    if 0 
        plot(pop(1,:), pop(2,:), 'b+', selection(1,:), selection(2,:), 'r*', elem(1), elem(2), 'k+')
        sleep(0.001);
    end

end

function [mu, d] = meanStd(pop)
   mu = mean(pop')';
   d = std(pop(:));
end


k = 10;
popsize = 200;
pop = ones(10,popsize) * 2;
pop += randn(size(pop)) * 5;


popsize = size(pop,2);

accepts = 0;
tries = 0;


for i=1:100000000
    
    sel = 1 + floor(rand * popsize);
    cur = pop(:,sel);
    if 0 
        pp = pop;
        pp(:,sel) = [];
        
         
        [mu1, d1] = findNN(pp, cur, k);
       
        nw = mu1 + randn(size(mu1)) * d1;
        
        sel2 = 1 + floor(rand * size(pp,2));

        [mu2, d2] = findNN(pp, nw, k);

        forw  = prob(mu1, d1, nw);
        backw = prob(mu2, d2, cur);
    elseif 0
        nw = cur + randn(size(cur)) * 0.3;
        forw = 1; backw = 1;
    elseif 0

        idx = [sel - k : sel + k];
        idx(idx == sel) = [];
        idx(idx<=0) += size(pop,2);
        idx(idx>size(pop,2)) -= size(pop,2);
        
        [mu, d] = meanStd(pop(:, idx));

        nw = mu + randn(size(mu)) * d;

        forw = prob(mu, d, nw);
        backw = prob(mu, d, cur);
    else 
        sel1 = 1 + floor(rand * size(pop,2));
        sel2 = 1 + floor(rand * size(pop,2));
        
        pp = pop;
        pp(:,sel1) = [];
        cur = pop(:,sel1);
        [mu1, d1] = findNN(pp, cur, k);
        
        pp = pop;
        pp(:,sel2) = [];
        cur = pop(:, sel2);
        [mu2, d2] = findNN(pp, cur, k);
        
        alt1 = mu1 + randn(size(mu1)) * d1;
        alt2 = mu2 + randn(size(mu2)) * d2;
        
        p1  = prob(mu2, d2, alt1);
        p2  = prob(mu1, d1, alt2);
        
        fit1 = fitness(alt1);
        fit2 = fitness(alt2);
        
        if rand < fit1 * p2 / (fit1 * p2 + fit2 * p1)
            pop(:, sel1) = alt2;
        else
            pop(:, sel2) = alt1;
        end


        % make sure later acceptance is 0
        backw = 0; forw = 1;
        nw = cur;
    end

    f1 = fitness(cur);
    f2 = fitness(nw);
    tries += 1;
    if rand < f2 / f1 * backw / forw 
        accepts += 1;
        pop(:, sel) = nw;
    end

    if rem(i,1000) == 0
        printf('accept rate %f, d = %f\n', accepts/tries, mean(std(pop')));
        disp(mean(pop'))
        accepts = 0;
        tries = 0;
        %hist(pop(1,:), 30);
        plot( pop(1,:), pop(2, :), '*')
        sleep(0.001);
    
        s1 = sum(all(pop < 2.5));
        s2 = sum(all(pop > 2.5));
        disp([popsize, s1, s2]);
    end
end


