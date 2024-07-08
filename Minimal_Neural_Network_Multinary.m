clc
clear
close all
disp('Reading data from Excel file')
data=readtable("CITRINE_hardness_dataset_sorted.xlsx");
nb_elements=7;
compo_variation=0.1; %for predicted data

%% Options for training
nbtraining = 10; %number of batches for training with k folding
nbkfold = 16;    %number of k folding = number of processors used in parallel
neurons_per_hidden_layer = 300; %the more the better but the higher the risk of overfitting, so the k-folding
options.Epochs = 1000; %Epochs are enough when fitting does not depends on this variable anymore

name_elements=["Al","Co","Cr","Fe","Ni","Ti","Mo"];
name_elements_array = {'Al','Co','Cr','Fe','Ni','Ti','Mo'};
Al=str2double(data.Al);
Co=str2double(data.Co);
Cr=str2double(data.Cr);
Fe=str2double(data.Fe);
Ni=str2double(data.Ni);
Ti=str2double(data.Ti);
Mo=str2double(data.Mo);
Compo=[Al Co Cr Fe Ni Ti Mo]; %descriptors
Training=data.HV;             %data to fit, this one is formatted differently in the source file, because

layers= [
    featureInputLayer(nb_elements); % number of descriptors
    fullyConnectedLayer(neurons_per_hidden_layer) %can be different for each layers as well as the deepness
    reluLayer() %looks like the best type of layer for this problem
    fullyConnectedLayer(neurons_per_hidden_layer)
    reluLayer()
    fullyConnectedLayer(neurons_per_hidden_layer)
    reluLayer()
    fullyConnectedLayer(neurons_per_hidden_layer)
    reluLayer()
    fullyConnectedLayer(1) %number of outputs to fit
    regressionLayer()
    ];

options.Save_yytest = true;
options.Seed = 123;
rng(options.Seed);

options = trainingOptions('rmsprop', ...
    'MaxEpochs', options.Epochs, ...
    'Verbose', false, 'ExecutionEnvironment','auto');

best_rmse = 1e9;
best_adj = 0;
history_RMSE=[];
history_adjrsquare=[];
best_net=[];

% Define the number of networks to save per batch and preallocate the structure
nets = cell(1, nbkfold);

disp(['Training the neural network, kfold running on ',num2str(nbkfold),' processors in parallel'])
for i=1:1:nbtraining
    %tic
    cvp = cvpartition(length(Compo), 'KFold', nbkfold);
    sub_RMSE_kfold=1e9*ones(nbkfold,1);
    sub_adjrsquare_kfold=zeros(nbkfold,1);
    parfor fold = 1:nbkfold %use for instead or parfor if you do not own the parallel computing library
        %using k-folding
        train_features = Compo(~cvp.test(fold), :); % data for training
        train_responses = Training(~cvp.test(fold), :);
        val_features = Compo(cvp.test(fold), :);  % data for testing
        val_responses = Training(cvp.test(fold), :);
        current_net = trainNetwork(train_features, train_responses, layers, options);
        nets{fold} = current_net;% stores the networks in a cell

        %Testing the current network trained from k-folding with the data fullset
        current_predictions = predict(current_net, Compo) 
        mdl = fitlm(current_predictions,Training); %it is possible to use a loss function too here
        sub_adjrsquare_kfold(fold,1)=mdl.Rsquared.Adjusted;
        sub_RMSE_kfold(fold,1)=rmse(current_predictions,Training);
    end
    history_RMSE=[history_RMSE;sub_RMSE_kfold];
    history_adjrsquare=[history_adjrsquare;sub_adjrsquare_kfold];
    figure(1)
    histogram(history_RMSE,20)
    title('RMSE over batches')
    fontsize(16,"points");
    drawnow
    for fold=1:1:nbkfold
        if sub_adjrsquare_kfold(fold) > best_adj
            best_rmse = sub_RMSE_kfold(fold);
            best_adj = sub_adjrsquare_kfold(fold);
            best_net=nets{fold};
            disp(['Best adjRsquared found: ', num2str(best_adj),' local RMSE ',num2str(best_rmse) , ' saving to mat file...'])
            save('BestNN.mat','best_net','-mat');
        end
    end
    disp(['Batch: ',num2str(i), '/',num2str(nbtraining), ' minRMSE: ',num2str(min(history_RMSE)) ,' meanRMSE: ',num2str(mean(history_RMSE)) ,' stdRMSE: ',num2str(std(history_RMSE))])
    %toc
end

Predictions = predict(best_net, Compo);
mdl = fitlm(Training,Predictions);
figure('Position',[100 100 1200 1000]);
subplot(2,2,1)
plot(Training,Predictions,'bd')
title(['Adjusted R squared: ',num2str(mdl.Rsquared.Adjusted)])
ylabel('Predicted')
xlabel('Actual')
fontsize(16,"points");

subplot(2,2,2)
qqplot(Training-Predictions)
title('Residuals trained data')
fontsize(16,"points");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x = gallery('uniformdata',[nb_elements 1],0);
y = gallery('uniformdata',[nb_elements 1],1);
z = gallery('uniformdata',[nb_elements 1],2);
DT = delaunayTriangulation(x,y,z);
[T,Xb] = freeBoundary(DT);
TR = triangulation(T,Xb);
coord_m=Compo*[x y z];
color=hot;
Output_scaled=(Training-min(Training))/(max(Training)-min(Training));
color_index_Output=(round(Output_scaled.*255)+1);
subplot(2,2,3)
title('Experimental hardness')
set(gca,'DefaultTextFontName','Helvetica','DefaultTextFontSize', 16)
set(gca,'color','w')
fontsize(16,"points");
hold on
tetramesh(DT,'FaceAlpha',0.05);
text(TR.Points(:,1),TR.Points(:,2),TR.Points(:,3),name_elements)
for i=1:size(Training,1)
    plot3(coord_m(i,1),coord_m(i,2),coord_m(i,3),'ok-','MarkerFaceColor',color(color_index_Output(i),:),'MarkerSize',Training(i)./100)
end
hold off
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Creating the composition table for prediction')
num_compo=1;
compo_predicted=[];
for e1 =0:compo_variation:1
    for e2=0:compo_variation:1-e1
        for e3=0:compo_variation:1-e1-e2
            for e4=0:compo_variation:1-e1-e2-e3
                for e5=0:compo_variation:1-e1-e2-e3-e4
                    for e6=0:compo_variation:1-e1-e2-e3-e4-e5
                        compo_predicted=[compo_predicted;[e1,e2,e3,e4,e5,e6,1-e1-e2-e3-e4-e5-e6]];
                        num_compo=num_compo+1;
                    end
                end
            end
        end
    end
end
disp('Calculating predicted data')
predNN=predict(best_net, compo_predicted);
predNN=max(0,predNN);% to remove if your predicted data are less than zero

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x = gallery('uniformdata',[nb_elements 1],0);
y = gallery('uniformdata',[nb_elements 1],1);
z = gallery('uniformdata',[nb_elements 1],2);
DT = delaunayTriangulation(x,y,z);
[T,Xb] = freeBoundary(DT);
TR = triangulation(T,Xb);
F = faceNormal(TR);
coord_m=compo_predicted*[x y z];
color=hot;
Output_scaled=(predNN-min(predNN))/(max(predNN)-min(predNN));
color_index_Output=(round(Output_scaled.*255)+1);
subplot(2,2,4)
title('Predicted hardness')
set(gca,'DefaultTextFontName','Helvetica','DefaultTextFontSize', 16)
set(gca,'color','w')
fontsize(16,"points");
hold on
tetramesh(DT,'FaceAlpha',0.05);
text(TR.Points(:,1),TR.Points(:,2),TR.Points(:,3),name_elements)
for i=1:size(predNN,1)
    plot3(coord_m(i,1),coord_m(i,2),coord_m(i,3),'ok-','MarkerFaceColor',color(color_index_Output(i),:),'MarkerSize',predNN(i)./300)
end
hold off
drawnow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Saving figure to png file')
saveas(gcf,'Figure.png');
disp('Saving figure to fig file')
savefig('Figure.fig')
disp('End of training, displaying the best compositions found by brute force:')
Best_compositions=[compo_predicted,predNN];
Best_compositions=sortrows(Best_compositions,nb_elements+1,"descend");
Best_compositions(1:10,1:end-1)