function least_squares()
    % Import the dataset as a table
    eqData = import_data("earthquake_data.csv");
    
    % Convert magType to a dummy variable
    magType = categorical(eqData.magType);
    magType = dummyvar(magType);

    % Initialize the matrix A and vector b
    %X = [eqData.magnitude, eqData.mmi, eqData.cdi]; % Original formulation
    X = [eqData.magnitude, eqData.mmi, eqData.cdi, eqData.tsunami, magType, eqData.depth, eqData.latitude, eqData.longitude];
    A = [ones(size(X,1),1), X];
    b = eqData.sig;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % CHOLESKY DECOMPOSITION
    %%%%%%%%%%%%%%%%%%%%%%%%%
    beta_chol = cholesky(A, b);
    yhat = A * beta_chol;           
    residuals = b - yhat;
    
    % Compute R^2
    R2_chol = 1 - sum(residuals.^2)/sum((b - mean(b)).^2);
    
    % Plot the observed values versus the predicted
    figure(1); clf;
    scatter(b, yhat, 'ro', 'filled'); hold on;
    plot([min(b), max(b)], [min(b), max(b)], 'k-', 'LineWidth', 2); % 1:1 line
    xlabel('Observed Significance Score (sig)');
    ylabel('Predicted Significance Score');
    title(sprintf('Cholesky Fit,   R^2 = %.4f', R2_chol));
    legend('Predicted vs Observed','1:1 Line','Location','best');
    grid on;
    drawnow;

    %%%%%%%%%%%%%%%%%%%
    % QR DECOMPOSITION
    %%%%%%%%%%%%%%%%%%%
    beta_qr = qr_decomp(A, b);
    yhat_qr = A * beta_qr;
    residuals = b - yhat_qr;

    % Compute R^2
    R2_qr = 1 - sum(residuals.^2)/sum((b - mean(b)).^2);

    % Plot the observed values versus the predicted
    figure(2); clf;
    scatter(b, yhat_qr, 'ro', 'filled'); hold on;
    plot([min(b), max(b)], [min(b), max(b)], 'k-', 'LineWidth', 2);
    xlabel('Observed Significance Score (sig)');
    ylabel('Predicted Significance Score');
    title(sprintf('QR Fit, R^2 = %.4f', R2_qr));
    legend('Predicted vs Observed','1:1 Line','Location','best');
    grid on;

    %%%%%%%%%%%%%%%%%%%%%%%
    % MATLAB BUILT-IN LSQR
    %%%%%%%%%%%%%%%%%%%%%%%
    beta_lsqr = lsqr(A, b, 1e-6, 100);
    yhat_lsqr = A * beta_lsqr;
    residuals = b - yhat_lsqr;
    
    % Compute R^2
    R2_lsqr = 1 - sum(residuals.^2)/sum((b - mean(b)).^2);

    % Plot the observed values versus the predicted
    figure(3); clf;
    scatter(b, yhat_lsqr, 'ro', 'filled'); hold on;
    plot([min(b), max(b)], [min(b), max(b)], 'k-', 'LineWidth', 2);
    xlabel('Observed Significance Score (sig)');
    ylabel('Predicted Significance Score');
    title(sprintf('LSQR Fit, R^2 = %.4f', R2_lsqr));
    legend('Predicted vs Observed','1:1 Line','Location','best');
    grid on;

    %%%%%%%%%%%%%%%%%%%%%%%%
    % PRINT COMPARISON DATA
    %%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('\nR^2 Comparison:\n');
    fprintf('Cholesky: %.6f\n', R2_chol);
    fprintf('QR:       %.6f\n', R2_qr);
    fprintf('LSQR:     %.6f\n', R2_lsqr);
    
    fprintf('\nMax absolute difference in coefficients:\n');
    fprintf('Cholesky vs QR:   %.6e\n', max(abs(beta_chol - beta_qr)));
    fprintf('Cholesky vs LSQR: %.6e\n', max(abs(beta_chol - beta_lsqr)));
    fprintf('QR vs LSQR:       %.6e\n', max(abs(beta_qr - beta_lsqr)));

   
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % TRAIN/TEST DATASETS
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % Parameters
    rng(1);
    n = size(A,1);              % number of observations
    idx = randperm(n);          % random permutation of indices
    train_frac = 0.7;           % 70% training
    nTrain = round(train_frac * n);
    train_idx = idx(1:nTrain);
    test_idx  = idx(nTrain+1:end);
    
    % Partition data
    A_train = A(train_idx,:);
    b_train = b(train_idx);
    A_test  = A(test_idx,:);
    b_test  = b(test_idx);

    % Cholesky
    beta_chol = cholesky(A_train, b_train);
    yhat_train_chol = A_train * beta_chol;
    yhat_test_chol  = A_test  * beta_chol;
    R2_train_chol = 1 - sum((b_train - yhat_train_chol).^2) / sum((b_train - mean(b_train)).^2);
    R2_test_chol  = 1 - sum((b_test  - yhat_test_chol).^2)  / sum((b_test  - mean(b_test)).^2);
    
    % QR
    beta_qr = qr_decomp(A_train, b_train);
    yhat_train_qr = A_train * beta_qr;
    yhat_test_qr  = A_test  * beta_qr;
    R2_train_qr = 1 - sum((b_train - yhat_train_qr).^2) / sum((b_train - mean(b_train)).^2);
    R2_test_qr  = 1 - sum((b_test  - yhat_test_qr).^2)  / sum((b_test  - mean(b_test)).^2);
    
    % LSQR
    beta_lsqr = lsqr(A_train, b_train, 1e-6, 100);
    yhat_train_lsqr = A_train * beta_lsqr;
    yhat_test_lsqr  = A_test  * beta_lsqr;
    R2_train_lsqr = 1 - sum((b_train - yhat_train_lsqr).^2) / sum((b_train - mean(b_train)).^2);
    R2_test_lsqr  = 1 - sum((b_test  - yhat_test_lsqr).^2)  / sum((b_test  - mean(b_test)).^2);
    
    % Print results
    fprintf('\nTraining vs Test R^2:\n');
    fprintf('Cholesky: Train = %.4f, Test = %.4f\n', R2_train_chol, R2_test_chol);
    fprintf('QR:       Train = %.4f, Test = %.4f\n', R2_train_qr, R2_test_qr);
    fprintf('LSQR:     Train = %.4f, Test = %.4f\n', R2_train_lsqr, R2_test_lsqr);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMPUTE THE CONDITION OF A
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cond_A = cond(A);
    fprintf('\nCondition number of A: %.2e\n', cond_A);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Gaussian Process Regression (GPR)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    gprMdl = fitrgp(A_train, b_train, ...
        'KernelFunction','squaredexponential', ...
        'Standardize',true);
    
    yhat_train_gpr = predict(gprMdl, A_train);
    yhat_test_gpr  = predict(gprMdl, A_test);
    
    R2_train_gpr = 1 - sum((b_train - yhat_train_gpr).^2) / sum((b_train - mean(b_train)).^2);
    R2_test_gpr  = 1 - sum((b_test  - yhat_test_gpr).^2)  / sum((b_test  - mean(b_test)).^2);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Ensemble Regression Trees
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ensMdl = fitrensemble(A_train, b_train, 'Method','Bag', 'NumLearningCycles',100);
    yhat_train_ens = predict(ensMdl, A_train);
    yhat_test_ens  = predict(ensMdl, A_test);
    R2_train_ens = 1 - sum((b_train - yhat_train_ens).^2) / sum((b_train - mean(b_train)).^2);
    R2_test_ens  = 1 - sum((b_test  - yhat_test_ens).^2)  / sum((b_test  - mean(b_test)).^2);
    
    % Report results
    fprintf('\nNonlinear Models: Training vs Test R^2\n');
    fprintf('GPR:       Train = %.4f, Test = %.4f\n', R2_train_gpr, R2_test_gpr);
    fprintf('Ensemble:  Train = %.4f, Test = %.4f\n', R2_train_ens, R2_test_ens);
    
    % Plot observed vs predicted for test set
    figure; hold on;
    scatter(b_test, yhat_test_gpr, 'bo', 'DisplayName','Test GPR');
    scatter(b_test, yhat_test_ens, 'gx', 'DisplayName','Test Ensemble');
    plot([min(b_test), max(b_test)], [min(b_test), max(b_test)], 'k-', 'LineWidth',2, 'DisplayName','1:1 Line');
    xlabel('Observed Significance Score (sig)');
    ylabel('Predicted Significance Score');
    title('Nonlinear Models: Test Set Predictions');
    legend('Location','best');
    grid on;
end


% Imports the dataset as a table and outputs the properties, variable
% names, and height and width. 
function data = import_data(fileName)
    data = readtable(fileName);
    % View dataset attributes
    data.Properties
    data.Properties.VariableNames
    % Table specific functions
    height(data) % num rows
    width(data) % num cols
end


% Manually forms the normal equations, then uses chol() to do a Cholesky
% decomposition to solve the normal equations for the unknown intercept and 
% slope of the best-fit line.
function x = cholesky(A,b)
    ATA = A' * A;
    ATb = A' * b;
    R = chol(ATA);
    z = fwdsub(R', ATb);
    beta = backsub(R, z);
    x = beta;
end

% Uses the QR decomposition of A to solve the least squares problem.
% factors A into Q (orthonormal columns) and R (upper triangular),
% then reduces the system to R*x = Q'*b, which is solved by back substitution.
function x = qr_decomp(A,b)
    [Q,R] = qr(A,0);
    rhs = Q' * b;
    x = backsub(R, rhs);
end


% This function solves the linear system Ax = b using forward substitution, 
% where A has the properties that it is real, square, and lower triangular.
function x = fwdsub(A,b)
    if all(all(A == tril(A)))
        n = size(A,1);
        x(1) = b(1)/A(1,1);
        for i = 2:n
            bigsum = A(i,1:i-1)*x(1:i-1)';
            x(i) = (b(i) - bigsum) / A(i,i);
        end
        x = x';
    else
        n = size(A,1);
        x = NaN(n,1);
    end
end

% This function solves the linear system Ax = b using backward substitution, 
% where A has the properties that it is real, square, and upper triangular.
function x = backsub(A,b)
    if all(all(A == triu(A)))
        n = size(A,1);
        x(n) = b(n)/A(n,n);
        for i = (n-1):-1:1
            bigsum = A(i,i+1:n)*x(i+1:n)';
            x(i) = (b(i) - bigsum) / A(i,i);
        end
        x = x';
    else
        n = size(A,1);
        x = NaN(n,1);
    end
end
