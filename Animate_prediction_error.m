clc
clear
close all
delete('Error_animated.gif')
nb_elements=7;
compo_variation=0.1; %for predicted data
name_elements=["Al","Co","Cr","Fe","Ni","Ti","Mo"];
disp('Reading data from Excel file')
data=readtable("CITRINE_hardness_dataset_sorted.xlsx");
Al=str2double(data.Al);
Co=str2double(data.Co);
Cr=str2double(data.Cr);
Fe=str2double(data.Fe);
Ni=str2double(data.Ni);
Ti=str2double(data.Ti);
Mo=str2double(data.Mo);
Compo=[Al Co Cr Fe Ni Ti Mo]; %composition position
XTX_1=[Compo'*Compo]^-1;%inverse of the variance-covariance matrix of experimental points

figure('Position',[100 100 900 900]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Creating the composition table for prediction, this may take a while...')
num_compo=1;
compo_predicted=[];
predError=[];
for e1 =0:compo_variation:1
    for e2=0:compo_variation:1-e1
        for e3=0:compo_variation:1-e1-e2
            for e4=0:compo_variation:1-e1-e2-e3
                for e5=0:compo_variation:1-e1-e2-e3-e4
                    for e6=0:compo_variation:1-e1-e2-e3-e4-e5
                        compo_vec=[e1,e2,e3,e4,e5,e6,1-e1-e2-e3-e4-e5-e6];
                        compo_predicted=[compo_predicted;compo_vec];
                        predError=[predError;compo_vec*(XTX_1)*compo_vec'];%the farther from an experimental point, the bigger the error, that's simple
                        num_compo=num_compo+1;
                    end
                end
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x = gallery('uniformdata',[nb_elements 1],0);
y = gallery('uniformdata',[nb_elements 1],1);
z = gallery('uniformdata',[nb_elements 1],2);
DT = delaunayTriangulation(x,y,z);
[T,Xb] = freeBoundary(DT);
TR = triangulation(T,Xb);
coord_m=compo_predicted*[x y z];
color=hot;
Output_scaled=(predError-min(predError))/(max(predError)-min(predError));
color_index_Output=(round(Output_scaled.*255)+1);
title('Predicted error based on point distribution')
set(gca,'DefaultTextFontName','Helvetica','DefaultTextFontSize', 16)
set(gca,'color','w')
fontsize(16,"points");
hold on
tetramesh(DT,'FaceAlpha',0.05);
text(TR.Points(:,1),TR.Points(:,2),TR.Points(:,3),name_elements)
for i=1:size(predError,1)
    plot3(coord_m(i,1),coord_m(i,2),coord_m(i,3),'ok-','MarkerFaceColor',color(color_index_Output(i),:),'MarkerSize',predError(i).*50)
end
hold off
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for j=0:4:360
    tic
    j
    view(j,0)
    exportgraphics(gca,"Error_animated.gif","Append",true)
    drawnow
    toc
end