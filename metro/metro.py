from random import *
from Numeric import *
from LinearAlgebra import *
from RandomArray import *
from MLab import *
import Gnuplot

objective_values = array([10,9,8,7,6,5,4,3,2,1,11,12,13,14,15,14,13,12,11,14,14,14,14,20,21,22,22,22,22,26,27,28], Float)
#objective_values = (arange( 32) + 1.0)
#objective_values = ones( (5,), Float )

objective_values = arange(255)+1.;
objective_values /= objective_values;
#l = list(objective_values[511:]);
#l.reverse()
#print len(l)
#objective_values[0:512] = l;

#objective_values = ones(shape(objective_values), Float)
#objective_values[1000:] = 2
#objective_values = log(objective_values);

#chromsize = len(objective_values)
chromsize = int(1 + log(len(objective_values)) / log(2.0))
print chromsize
mprob = 1.0 / chromsize;

def dec(chrom):
    val = 0;
    j = 1;
    for i in chrom:
	val += j * i
	j *= 2
    return val


#decode = sum
decode = dec

def calc_worth(chrom):
    
    val = decode(chrom);

    if val >= len(objective_values):
	return 0.0;
    
    return objective_values[val];

def to_prob(x):
    return 1 / (1 + exp(-x))
def from_prob(p):
    return -log( 1/p - 1)

class Indy:
    adapt = 1
    adapt_individually = 0

    def __init__(self, chrom):
	self.chrom = chrom
	self.w = 0.0;
	
	self.m = from_prob(mprob)

    def eval(self):
	self.w = calc_worth(self.chrom)

    def mutate(self):
	m = to_prob(self.m)
		
	if Indy.adapt_individually:
	    m = to_prob(self.mutations)
	
	mask = rand( chromsize ) < m;
	indy = Indy(bitwise_xor(self.chrom, mask))

	if Indy.adapt:
	    indy.m = normal(self.m, 0.1)
	
	return indy
    
    def probability(self, dest):
	# probability of generating dest from self
	m = to_prob(self.m) 
	diff = sum(bitwise_xor(dest.chrom, self.chrom))
	mut = pow(m, diff)
	stay = pow(1-m, chromsize - diff)
	
	#print m, diff, chromsize - diff, chromsize, mut, stay 
	
	return mut * stay
   
def transmission_matrix(pop):
    C = zeros( (len(pop), len(pop)), Float);
    for i in range(len(pop)):
	for j in range(len(pop)):
	    p = pop[i].probability(pop[j])

	    C[i,j] = p

    return C

def method1(TXX, TXy, C, pop, new, tyX):
    acc = 0.
    r = int(rand() * len(pop))
    txX = TXX[r] + TXy[r] - C[r,r]
    
    if txX == 0:
	return 0.0,0,0
    
    indy = pop[r]	
    
    try:
	wor = beta * (new.w - indy.w)
	trans = (log(txX) - log(tyX) ) #* beta
	
	perf = wor + trans
	
	acc += exp(perf) / len(pop) 

    except OverflowError:
	if perf > 0.0:
	    acc = 1.0 
	else:
	    acc = 0.
   
    return acc, r, 1

def method2(TXX, TXy, C, pop, new, tyX):

    acc = zeros( (len(pop),), Float)
    
    for i in range(len(pop)):
	#i = r # previous approach
	txX = TXX[i] + TXy[i] - C[i,i]

	if txX == 0.0:
	    continue;

	indy = pop[i]	
	
	try:
	    wor = beta * (new.w - indy.w)
	    trans = (log(txX) - log(tyX) ) #* beta
	    
	    perf = wor + trans
	    
	    acc[i] = min([1.0, exp(perf)]) 
	    #acc[i] = exp(perf)
	    #acc[i] = exp(new.w) / (exp(new.w) + exp(indy.w)) * txX / (txX + tyX)

	except OverflowError:
	    if perf > 0.0:
		acc[i] = 1.0
	    else:
		acc[i] = 0.0
	    break;    
   
    # now select r
    sumacc = sum(acc);
    fortune = rand() * len(pop); orgf = fortune
    if fortune >= sumacc:
	# no go
	return 0.0, 0, 1

    r = 0
    while fortune >= 0:
	fortune -= acc[r]
	r += 1

    r -= 1
    return 1.0, r, 1

def method3(TXX, TXy, C, pop, new, tyX):

    r = int(rand() * len(pop)) 
    txX = TXX[r] + TXy[r] - C[r,r]

    bolzmann = txX / (txX + tyX)

    if rand() >= bolzmann:
	return 0.0, r, 0

    try:
	perf = beta * (new.w - indy.w)
	
	acc = exp(perf)
    except OverflowError:
	if perf > 0.0:
	    acc = 1.0
	else:
	    acc = 0.0
  
    return acc, r, 1
  
def method23(TXX, TXy, C, pop, new, tyX):
    
    bolz = zeros( (len(pop),), Float)
    
    best = pop[0]
    for i in range(len(pop)):
	txX = TXX[i] + TXy[i] - C[i,i]
	bolz[i] = txX / (txX + tyX)

	if pop[i].w > best.w:
	    best = pop[i]
	
    # now select r
    sumbolz = sum(bolz);
    fortune = rand() * len(pop);
   
    if fortune >= sumbolz:
    #if fortune < sumbolz:
    # no go
	return 0.0, 0, 0 # no evaluation neccessary 
   
    #fortune = rand() * sumbolz;

    r = 0
    while fortune >= 0:
	fortune -= bolz[r]
	r += 1

    r -= 1
    indy = pop[r]
    try:
	perf = beta * (new.w - indy.w)
	
	acc = exp(perf)
    except OverflowError:
	if perf > 0.0:
	    acc = 1.0
	else:
	    acc = 0.0
  
    return acc, r, 1

popsize= 15
walkp = 0.
beta0 = 1e-9 
beta = beta0

Indy.adapt = 0 
mprob = 0.001

if __name__ == '__main__':

    lastevals = 0. 
    evals = 0.;
    counts = []
    #togen = []
    g = Gnuplot.Gnuplot()
    g.reset()
    pop = []
    for i in range(popsize):
	chrom = zeros((chromsize,))#rand(chromsize) > 0.5;
	indy = Indy(chrom)
	indy.eval()
	pop.append(indy)
    
    accepts = 0
    acount = 0
    transmission = 0.
    popsize = len(pop) 
   
    if walkp < 1 or Indy.adapt == 1:
	C = transmission_matrix(pop)
     
    for iter in xrange(1000000000L):
	
	beta  = 1#evals+1
	select = int(rand() * len(pop))
	
	new = pop[select].mutate()
	
	new.eval()
	
	if (walkp < 1 or Indy.adapt == 1):
	    TyX = zeros( (popsize,), Float)
	    TXy = zeros( (popsize,), Float)
	    
	    for i in range(len(pop)):
		TyX[i] = pop[i].probability(new)
		TXy[i] = new.probability(pop[i])
		
	    tyX = sum(TyX);
	    TXX = sum(C,1); # sum over columns, row totals
	r = int(rand() * len(pop))	

	perf = 0.
	if rand() < walkp:
	    r = select
	    
	    try:
		del perf
		perf = beta * (new.w - pop[r].w)
		acc = exp(perf) 

		# Bolzmann
		#acc = exp(new.w) / (exp(pop[r].w) + exp(new.w))
	
		if Indy.adapt:
		    acc *= TXy[select] / TyX[select]
	    except OverflowError:
		#print 'Overflow', new.w, indy.w, beta, perf
		if perf >= 0.0:
		    acc = len(pop) * 1.1 
		else:
		    acc = 0.
	
	    evals += 1
	
	else:
	    #(acc,r, e) = method1(TXX, TXy, C, pop, new, tyX) 
	    #(acc,r, e) = method2(TXX, TXy, C, pop, new, tyX)
	    #(acc,r, e) = method3(TXX, TXy, C, pop, new, tyX)
	    (acc,r, e) = method23(TXX, TXy, C, pop, new, tyX)
	    
	    evals += e
	    
	if  rand() < acc:
	    
	    pop[r] = new
	    accepts += 1		 
	   
	    if (walkp < 1 or Indy.adapt == 1):
		C[r,:] = TXy
		C[:,r] = TyX
		C[r,r] = new.probability(new)

		#D = transmission_matrix(pop)

		#print 'sum', len(pop) * len(pop), sum( (D == C).flat)

	acount += 1	
	if (evals-lastevals)==100 or iter == 0:
	    index = []
	    worth = []
	    w = [] 
	    
	    for indy in pop:
		val = decode(indy.chrom)
		index.append( val )
		worth.append( indy.w)
		w.append(decode(indy.chrom))
		
		while len(counts) <= val:
		    counts.append(0)
		counts[val] += 1;

	    
	    now = zeros( (len(counts),), Float)
	    for indy in pop:
		val = decode(indy.chrom)
		now[val] += 1;
		

	    d = Gnuplot.Data(index, worth, with = 'points')
	    
	    ind = arange(len(objective_values))
	    d2  = Gnuplot.Data(ind, objective_values, with='lines') 
	    
	    cnt = array(counts, Float)
	    cnt /= maximum.reduce(cnt) 
	    cnt *= maximum.reduce(objective_values) * 0.25

	    d3 = Gnuplot.Data( arange(len(counts)), cnt, with = 'boxes');
	    
	    now /= maximum.reduce(now) 
	    now *= maximum.reduce(objective_values) * 0.25

	    d4 = Gnuplot.Data( arange(len(now)), now, with = 'boxes');
	    
	    g.plot(d,d2, d3,d4)
	    
	    mutations = array(map(lambda x: to_prob(x.m), pop), Float)
	    mrate = mean(mutations)
	    srate = std(mutations)
	    
	    print "iter %d, popsize %d"%(iter, len(pop)), accepts / float(acount), beta, "mean %.3f std %.4f"%(mrate,srate), "%.2f %.2f"%(evals / (iter + 1), (evals-lastevals)/100.), \
	    "%.2f"%( accepts / (1+evals-lastevals))

	    accepts = 0; acount = 0; transmission = 0.
	    lastevals = evals
	    
    print accepts
