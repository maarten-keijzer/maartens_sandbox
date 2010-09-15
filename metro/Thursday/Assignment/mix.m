% Simple script to do EM for a mixture of Gaussians.
% -------------------------------------------------

% Generate some data:

x = [randn(1,50)-2 randn(1,50)+2 0.1*randn(1,50) 3*randn(1,50)-1]'; 
xorg = x;

% Initialise parameters

n = length(x);        % number of observations

    k = 3;                % number of components
    p = ones(1,k)/k;      % mixing proportions
    mu = randn(1,k);      % means
    s2 = -log(rand(1,k)); % variances
    z = linspace(-7.5,7.5,1001)';
    N = length(z);


for t=1:1000

%x = xorg( floor(rand(n, 1) * n) + 1);

  % Do the E-step:

  Z = sum((ones(N,1)*(p./sqrt(s2))).* ...
                    exp(-0.5*(z*ones(1,k)-ones(N,1)*mu).^2./(ones(N,1)*s2)),2);
  
%  pause(1)

  Q = (ones(n,1)*(p./sqrt(s2))).* ...
                       exp(-0.5*(x*ones(1,k)-ones(n,1)*mu).^2./(ones(n,1)*s2));

  E(t) = sum(log(sum(Q,2)));       % compute cost
  if mod(t,100)==1; 
    hold off
    hist(x,linspace(-7.5,7.5,200));
    hold on
    plot(z,5*Z,'r'); 
    hold off
  end
    fprintf('Iteration: %i  log likelihood: %4.3e\r', t, E(t));
   
  if t>1 && E(t)-E(t-1) < 1e-4
    break;
  end
   
  Q = Q ./ (sum(Q,2)*ones(1,k));    % Normalise

  % Do the M-step:

  mu = (x'*Q)./sum(Q,1);
  s2 = sum(Q.*(x*ones(1,k)-ones(n,1)*mu).^2,1)./sum(Q,1);
  p = mean(Q);


end








