#include <iostream>
#include <vector>

using namespace std;

template <typename T> T random(T mx)	         { return static_cast<T>(1./(1.+RAND_MAX) * rand() * mx); }

class Eval {
    vector<unsigned> scramble;
    vector<bool> indy;
    
    public:

    Eval(int n) {
	scramble.resize(n);
	for (unsigned i = 0; i < scramble.size(); ++i) scramble[i] = i;
	//random_shuffle(scramble.begin(), scramble.end());
	indy.resize(n);
    }
	
    double evaluate(const vector<bool>& g) {
	// destroy any positional correlations
	//for (unsigned i = 0; i < scramble.size(); ++i) {
	//    indy[i] = g[scramble[i]];
	//}
	indy = g;
	// fitness function
	unsigned k = 4; //indy.size()/10;
	double hits = 0.0;
	for (unsigned i = 0; i < indy.size(); i += k) {
	    int nones = 0;
	    for (unsigned j = i; j < i+k; ++j) {
		if (indy[j]) nones++;
	    }
	    if (nones == k) {
		hits++;
	    }
	    else {
		hits += double(k-nones) / (k+1);
	    }
	}

	return hits;
    } 
    
};

void mutate(vector<unsigned>& scramble) {
    double p = 1./scramble.size();
    for (unsigned i = 0; i < scramble.size(); ++i) {
	if (random(1.0) < p) {
	    int oth = random(scramble.size());
	    if (oth != i) 
		swap(scramble[i], scramble[oth]); 
	}
    }
}

void mutate(vector<bool>& genes) {
    double p = 1./genes.size();
    for (unsigned i = 0; i < genes.size(); ++i) {
	if (random(1.0) < p) {
	    genes[i] = !genes[i];
	}
    }
}

void crossover(vector<bool>& g1, const vector<bool>& g2, const vector<unsigned>& scramble) {
    
    unsigned xspot = random(scramble.size());
    for (unsigned i = xspot; i < scramble.size(); ++i) {
	g1[ scramble[i] ] = g2[ scramble[i] ];
    }
}
    
struct Genotype { 
    vector<bool> genes;
    vector<unsigned> scramble;
    double fitness;
    
    void init(int n) {
	genes.resize(n);
	scramble.resize(n);
	for (unsigned i = 0; i < scramble.size(); ++i) {
	    genes[i] = random(2);
	    scramble[i] = i;
	}

	random_shuffle(scramble.begin(), scramble.end());
    }
};

unsigned gene_len = 80;
unsigned popsize = 500;

int main()
{
    Eval eval(gene_len);
    vector<Genotype> pop(popsize);
    
    for (unsigned i = 0; i < pop.size(); ++i) {
	pop[i].init(gene_len);
	pop[i].fitness = eval.evaluate(pop[i].genes);
    }
    
    double best = 0.0;
    
    for (unsigned iter=0; iter < 100000; ++iter) {
	
	for (unsigned i = 0; i < pop.size(); ++i) {
	    
	    // pick partner
	    unsigned j = random(pop.size());
	    while (j == i) j = random(pop.size());
	    
	    Genotype child = pop[i];

	    crossover(child.genes, pop[j].genes, pop[j].scramble);	    
	    
	    child.scramble = pop[j].scramble;
	    mutate(child.scramble);
	    mutate(child.genes);

	    child.fitness = eval.evaluate(child.genes);

	    if (random(1.0) < exp(child.fitness - pop[i].fitness)) {
		pop[i] = child;
		
		if (child.fitness > best) {
		    best = child.fitness;
		    cout << child.fitness;
		    cout << ' ';
		    for (unsigned j = 0; j < child.genes.size(); ++j) {
			cout << child.genes[j];
		    }
		    cout << '\n';
		    for (unsigned j = 0; j < child.scramble.size(); ++j) {
			cout << child.scramble[j] << ' ';
		    }
		    cout << '\n';
		}
	    }
	    
	}
	
    }
    
}
