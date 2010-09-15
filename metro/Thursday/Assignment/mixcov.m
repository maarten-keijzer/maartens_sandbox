% Simple script to do EM for a mixture of Gaussians.
% -------------------------------------------------

% Generate some data:

load X
x = X;

% Initialise parameters

n = size(x,1);        % number of observations
d = size(x,2);        % number of dimensions

k = 4;                % number of components
p = ones(1,k)/k;      % mixing proportions
mu = randn(k, d) * 15;      % means
s2 = -log(rand(1,k)); % variances

clear covs
clear Q

for i = 1:k
 covs(i,:,:) =  cov(x);
end

z = linspace(-7.5,7.5,1001)';
N = length(z);

for t=1:100

%x = xorg( floor(rand(n, 1) * n) + 1);

  % Do the E-step:

 % hold off
 % hist(x,linspace(-7.5,7.5,200));
 % hold on
 % Z = sum((ones(N,1)*(p./sqrt(s2))).* ...
 %                   exp(-0.5*(z*ones(1,k)-ones(N,1)*mu).^2./(ones(N,1)*s2)),2);
 % plot(z,5*Z,'r')
 %    drawnow;
%  pause(1) 

hold off;
plot3(X(:,1),X(:,2),X(:,3),'o')
hold on;

plot3(mu(:,1), mu(:,2), mu(:,3), 'g*')

for i = 1:k
%  [a,b] = eig(covs(i,:,:));

  
end


drawnow


for i = 1:k
  meanvec = x - repmat(mu(i, :), n, 1);
  covar = reshape(covs(i,:,:), d, d);  
  invcovar = inv(covar);
  quadrat = (meanvec * invcovar) .* meanvec;
  quadrat = sum(quadrat,2);
  Q(:,i)  = (p(i)./sqrt(det(covar))) .* ...
         exp(-0.5* quadrat );
end

  E(t) = sum(log(sum(Q,2)));       % compute cost
  fprintf('Iteration: %i  log likelihood: %4.3e\r', t, E(t));
  Q = Q ./ (sum(Q,2)*ones(1,k));    % Normalise

  % Do the M-step:

  mu = ((x'*Q)./repmat(sum(Q,1),d,1))';

for i = 1:k
  meanvec = x - repmat(mu(i, :), n, 1);
  theQ = Q(:,i);
  covar =((repmat(theQ,1,d) .* meanvec)' * meanvec) ./sum(theQ);  
  covs(i, :, :) = covar;
end
  
p = mean(Q);

end








