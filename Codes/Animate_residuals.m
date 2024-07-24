clc
clear
close all
delete('Residuals_animated.gif')
disp('Reading data from Excel file')
data=readtable("CITRINE_hardness_dataset_sorted.xlsx");
nb_elements=7;

name_elements=["Al","Co","Cr","Fe","Ni","Ti","Mo"];
Al=str2double(data.Al);
Co=str2double(data.Co);
Cr=str2double(data.Cr);
Fe=str2double(data.Fe);
Ni=str2double(data.Ni);
Ti=str2double(data.Ti);
Mo=str2double(data.Mo);
Compo=[Al Co Cr Fe Ni Ti Mo]; %descriptors
Exp_data=data.HV;             %data to fit, this one is formatted differently in the source file, because

disp('Loading best NN network from previous calculation')
load('BestNN.mat')
disp('Calculating predicted data')
predNN=predict(best_net, Compo);
residuals=abs(predNN-Exp_data);

figure('Position',[100 100 900 900]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x = gallery('uniformdata',[nb_elements 1],0);
y = gallery('uniformdata',[nb_elements 1],1);
z = gallery('uniformdata',[nb_elements 1],2);
DT = delaunayTriangulation(x,y,z);
[T,Xb] = freeBoundary(DT);
TR = triangulation(T,Xb);
coord_m=Compo*[x y z];
color=jet;
Output_scaled=(residuals-min(residuals))/(max(residuals)-min(residuals));
color_index_Output=(round(Output_scaled.*255)+1);
title('Neural Network residuals')
set(gca,'DefaultTextFontName','Helvetica','DefaultTextFontSize', 16)
set(gca,'color','w')
fontsize(16,"points");
hold on
tetramesh(DT,'FaceAlpha',0.05);
text(TR.Points(:,1),TR.Points(:,2),TR.Points(:,3),name_elements)
for i=1:size(residuals,1)
    plot3(coord_m(i,1),coord_m(i,2),coord_m(i,3),'ok-','MarkerFaceColor',color(color_index_Output(i),:),'MarkerSize',residuals(i)./5)
end
hold off
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for j=0:2:360
    tic
    j
    view(j,0)
    exportgraphics(gca,"Residuals_animated.gif","Append",true)
    drawnow
    toc
end