clc
clear
close all
delete('Predicted_animated.gif')
nb_elements=7;
compo_variation=0.1; %for predicted data
name_elements=["Al","Co","Cr","Fe","Ni","Ti","Mo"];
disp('Loading best NN network from previous calculation')
load('BestNN.mat')
figure('Position',[100 100 900 900]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Creating the composition table for prediction, this may take a while...')
num_compo=1;
compo_predicted=[];
for e1=0:compo_variation:1+eps%eps is to avoid skipping points due to rounding errors
    for e2=0:compo_variation:1-e1+eps
        for e3=0:compo_variation:1-e1-e2+eps
            for e4=0:compo_variation:1-e1-e2-e3+eps
                for e5=0:compo_variation:1-e1-e2-e3-e4+eps
                    for e6=0:compo_variation:1-e1-e2-e3-e4-e5+eps
                        compo_predicted=[compo_predicted;[e1,e2,e3,e4,e5,e6,1-e1-e2-e3-e4-e5-e6]];
                        num_compo=num_compo+1;
                    end
                end
            end
        end
    end
end
compo_predicted=round(compo_predicted,6);%to deal with rounding approximations, again
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
color=jet;
Output_scaled=(predNN-min(predNN))/(max(predNN)-min(predNN));
color_index_Output=(round(Output_scaled.*255)+1);
title('Predicted Vickers hardness')
set(gca,'DefaultTextFontName','Helvetica','DefaultTextFontSize', 16)
set(gca,'color','w')
fontsize(16,"points");
hold on
tetramesh(DT,'FaceAlpha',0.05);
text(TR.Points(:,1),TR.Points(:,2),TR.Points(:,3),name_elements)
for i=1:size(predNN,1)
    plot3(coord_m(i,1),coord_m(i,2),coord_m(i,3),'ok-','MarkerFaceColor',color(color_index_Output(i),:),'MarkerSize',predNN(i)./50)
end
hold off
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for j=0:4:360
    tic
    j
    view(j,0)
    exportgraphics(gca,"Predicted_animated.gif","Append",true)
    drawnow
    toc
end