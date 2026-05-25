clc;
clear;
% INPUT
n = input('Enter matrix size n: ');
A = zeros(n,n);

disp('Enter the matrix row by row:');
for i = 1:n
    for j = 1:n
        A(i,j) = input(sprintf('A(%d,%d) = ', i, j));
    end
end

% INITIALIZATION
Ak = A;
Q_total = eye(n);        % Accumulate eigenvectors
eigenvalues = zeros(n,1);

tol = 1e-10;
m = n;                   % Active matrix size
total_iterations = 0;

% Detect symmetry
is_symmetric = norm(A - A.', 'fro') < tol;
% QR ITERATION WITH DEFLATION
while m > 1

    % -----------------------------
    % 1×1 Deflation
    % -----------------------------
    if abs(Ak(m,m-1)) < tol
        eigenvalues(m) = Ak(m,m);
        m = m - 1;
        continue;
    end
    % 2×2 Block (analytic solution)
    if m == 2
        a = Ak(1,1);
        b = Ak(1,2);
        c = Ak(2,1);
        d = Ak(2,2);

        trace_val = a + d;
        det_val = a*d - b*c;
        disc = trace_val^2 - 4*det_val;

        if disc >= 0
            eigenvalues(1) = (trace_val + sqrt(disc))/2;
            eigenvalues(2) = (trace_val - sqrt(disc))/2;
        else
            eigenvalues(1) = trace_val/2 + 1i*sqrt(-disc)/2;
            eigenvalues(2) = trace_val/2 - 1i*sqrt(-disc)/2;
        end
        break;
    end

    
    % Iterate until subdiagonal becomes small

    while abs(Ak(m,m-1)) > tol

     
        % SHIFT SELECTION
   
        if is_symmetric
            
            d = (Ak(m-1,m-1) - Ak(m,m))/2;
            if d == 0
                s = 1;
            else
                s = sign(d);
            end
            mu = Ak(m,m) - s * (Ak(m,m-1)^2) / ...
                 (abs(d) + sqrt(d^2 + Ak(m,m-1)^2));
        else
            % Rayleigh shift
            mu = Ak(m,m);
        end

       
        % GRAM–SCHMIDT QR
        
        Q = zeros(m,m);
        R = zeros(m,m);

        for j = 1:m

            % Take column j
            u = Ak(1:m,j);

            % Apply shift (subtract μ from diagonal entry only)
            u(j) = u(j) - mu;

            % Orthogonalization
            for i = 1:j-1
                R(i,j) = Q(:,i).' * u;
                u = u - R(i,j) * Q(:,i);
            end

            R(j,j) = norm(u);
            Q(:,j) = u / R(j,j);
        end

        
        % RQ STEP WITH SHIFT
        
        Ak(1:m,1:m) = R*Q + mu*eye(m);

        
        % ACCUMULATE EIGENVECTORS
     
        Q_total(:,1:m) = Q_total(:,1:m) * Q;

        total_iterations = total_iterations + 1;
    end
end

% Final 1×1 block

if m == 1
    eigenvalues(1) = Ak(1,1);
end

% OUTPUT

disp(' ');
disp('Eigenvalues:');
disp(eigenvalues);

disp('Eigenvectors (columns):');
disp(Q_total);

disp(['Total QR iterations: ', num2str(total_iterations)]);