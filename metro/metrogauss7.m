
dummy = 1;

function x = gauss(x)
    z = x - 5;
    %y = x + 1;
    %x = exp( - 0.5 * (x.*x) ) + exp( -0.5 * (z.*z)) + 2*exp(-0.5 * (y.*y));
    %x = exp( -0.5 * (x.*x) ) + exp(-0.5 * (z.*z));
     x = exp( -0.5 * (x.*x) );
end


function p = mutprob(x, y, s)
     
     p = 1 / sqrt(2 * pi * s * s) * exp( -1/2 * (x - y)^2 / (s*s));

end

def = 0;
pop = randn(1+def,1);
all = pop;
w = gauss(pop);

mutrate = randn(size(pop)) - 4;
allm = mutrate;

acc=0;
tries=0;
temp = 1;

for gen=1:10000000
    
    n = size(pop,1);
    tries+=1;
    
    if 0 
	i = 1 + floor(rand * n);
	new = pop(i) + randn * mutrate;
	
        p = gauss(new) / gauss(pop(i)); 

	if rand < p # accept
	     acc += 1;
	     pop(i,:) = new;
             w(i) = gauss(new);
	end
	
        all = [all;pop(i)];
    
    else 
        
        if rem(gen,2) == 0 # add
            i = 1 + floor(rand * n);
            c = i;%1 + floor(rand * n);
            
            newm = mutrate(c) + randn * 0.1;
            new = pop(i) + randn * exp(newm);
                  
            p = (def + n)/(def + n+1) *  (1 + gauss(new) / sum(w)); 

            if rand < p ^ temp # accept
                 acc += 1;
                 pop = [pop;new];
                 mutrate = [mutrate;newm];
                 w = [w;gauss(new)];
            end
            
        else
             if n==1
                 continue;
             end

             sel = 1 + floor(rand * n);

             sumw = sum(w);
             wx = sumw - w(sel);
             
             p = (def + n + 1) / (def + n) * wx / sumw; 

             if rand < p ^ temp #accept
                 acc += 1;
                 pop(sel) = [];
                 mutrate(sel) = [];
                 w(sel) = [];
             end
            
        end
        
        if rem(gen, 50) == 0
            sw = cumsum(w);
            f = rand * sw(end);
            i = find( f < sw);
            i = i(1);	
            all = [all;pop(i)];
            allm = [allm; mutrate(i)];
        end
    end

    if rem(gen,5000) == 0 
	more off;
	printf('gen %d, mean %f, std %f, mut %f %f, acc rate %f n = %d\n', gen, mean(all), std(all), mean(exp(allm)), max(exp(mutrate)), acc/tries, size(pop,1));
	%hist(pop,150);

	hist(all,150);
        %hold on
        %plot(pop, zeros(size(pop)), 'b*');
        %hold off

        if (length(all) > 50000) 
            start = 1 + floor(rand*2);
            all = all(start:2:end);
        end
    end
   
end

