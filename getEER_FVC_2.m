function [EER,scoreEER,espacio,FR,FA]=getEER_FVC_2(score,V_F)
%			[FA,FR,EER]=dib_FA_FR(score,V_F)
%Calcula y dibuja las curvas de "escalones" de Falsa Aceptaci�n y Falso Rechazo
%	* score: vector con las puntuaciones
%	* V_F: vector que contiene la naturaleza de cada firmante:
%			1 - Original
%			0 - Impostor
%	* EER: Equal Error Rate
%
%C�lculo de EER seg�n el criterio de IEEE(Vol24.N�3.Marzo 2002)

inicio=min(min(score));
fin=max(max(score));
espacio=min(min(score)):0.0001:max(max(score));

%'scores' de la curva FR
scr_FR=score(find(V_F==1));
num_orig=length(scr_FR);

%'scores' de la curva FA
scr_FA=score(find(V_F==0));
num_falsas=length(scr_FA);

%Obtenci�n de las curvas de Falsa Aceptaci�n y Falso Rechazo
fdp_FR=hist(scr_FR,espacio)/num_orig; 				
fdp_FA=hist(scr_FA,espacio)/num_falsas;
FR=cumsum([0 fdp_FR]);                  % Atencion a la definicion de FNMR y FMR en TPAMI
FR=FR(1:length(fdp_FR));
FA=fdp_FA;
for k=length(FA)-1:-1:1,
   FA(k)=FA(k)+FA(k+1);
end

indice_scores = find((fdp_FR>0)|(fdp_FA>0));
FR_scores = FR(indice_scores);
FA_scores = FA(indice_scores);

indice_t1=max(find(FR_scores <= FA_scores));    %�ndice de la posici�n m�xima para la que FR<=FA
indice_t2=min(find(FR_scores >= FA_scores)); %�ndice de la posici�n m�nima para la que FR>=FA

t1 = espacio(indice_scores(indice_t1));
t2 = espacio(indice_scores(indice_t2));

scoreEER = (t1 + t2)/2;

FR_t1=FR_scores(indice_t1);     %Valor de la curva FR en el umbral 't1'
FA_t1=FA_scores(indice_t1);   %Valor de la curva FA en el umbral 't1'
FR_t2=FR_scores(indice_t2);     %Valor de la curva FR en el umbral 't2'
FA_t2=FA_scores(indice_t2);   %Valor de la curva FA en el umbral 't2'
      
%C�lculo de EER_low y EER_high
if (FR_t1+FA_t1)<=(FR_t2+FA_t2) 
   EER_low=FR_t1;
   EER_high=FA_t1;
else
   EER_low=FA_t2; 	
   EER_high=FR_t2;
end

   %Obtenci�n de EER
EER =((EER_low+EER_high)/2)*100;


%Presentaci�n por pantalla

 figure,					%%%%%%%%%%%%%%%
 stairs(espacio,100*FR,'b'),hold on,stairs(espacio,100*FA,'r')				%%%%%%%%%%%%%CAMBIO 7 (J.Fierrez)
 axis([min(min(score)) max(max(score)) 0 100]),legend('FR (in %)','FA (in %)')             %%%%%%%%%%%%%%CAMBIO 6 (J.Fierrez)
 xlabel(['EER = ' num2str(EER) '% en score = ' num2str(round(scoreEER*1000)) '/1000'])
 hold off
  %datos = [FR_t1,FA_t1,FA_t2,FR_t2];
