clc
clear
close all
delete('Predicted_animated_rescaled.gif')
nb_elements=7;
compo_variation=0.1; %for predicted data
threshold_hardness=1000 % does not plot values below this threshold
name_elements=["Al","Co","Cr","Fe","Ni","Ti","Mo"];
disp('Loading best NN network from previous calculation')
load('BestNN.mat')
figure('Position',[100 100 900 900]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Creating the composition table for prediction, this may take a while...')
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x = gallery('uniformdata',[nb_elements 1],0);
y = gallery('uniformdata',[nb_elements 1],1);
z = gallery('uniformdata',[nb_elements 1],2);
DT = delaunayTriangulation(x,y,z);
[T,Xb] = freeBoundary(DT);
TR = triangulation(T,Xb);
coord_m=compo_predicted*[x y z];
color=hot;
Output_scaled=(predNN-threshold_hardness)/(max(predNN)-threshold_hardness);
color_index_Output=(round(Output_scaled.*255)+1);
title('Predicted Vickers hardness (rescaled)')
set(gca,'DefaultTextFontName','Helvetica','DefaultTextFontSize', 16)
set(gca,'color','w')
fontsize(16,"points");
hold on
tetramesh(DT,'FaceAlpha',0.05);
text(TR.Points(:,1),TR.Points(:,2),TR.Points(:,3),name_elements)
for i=1:size(predNN,1)
    if predNN(i)>threshold_hardness
        plot3(coord_m(i,1),coord_m(i,2),coord_m(i,3),'ok-','MarkerFaceColor',color(color_index_Output(i),:),'MarkerSize',(predNN(i)-threshold_hardness)./20)
    end
end
hold off
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for j=0:4:360
    tic
    j
    view(j,0)
    exportgraphics(gca,"Predicted_animated_rescaled.gif","Append",true)
    drawnow
    toc
end